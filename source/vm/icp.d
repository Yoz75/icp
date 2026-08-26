module vm.icp;

import vm.presets;
import vm.image;
import view;
import icp.color;
import icp.image;
import icp.filters;
import std.sumtype;
import std.algorithm : remove;
import std.string : strip, splitLines;
import imageformats;
import dlangui;

/// ICP view model
public final class ICP_VM
{
    private Preset selectedPreset;
    
    /// Expected errors of process method. Note that process MAY throw an exception on an unexpected error (null imagePath, devision by zero etc)
    public enum ProcessError
    {
        /// Uninitialized value
        none = 0,
        /// Image format is not RGBA
        wrongImageFormat,
        /// Image is corrupted and can not be loaded
        corruptedImage
    }

    public void selectPreset(Preset preset, WidgetGroup viewVidget)
    {
        if(selectedPreset !is null) selectedPreset.disable();
        
        selectedPreset = preset;
        selectedPreset.enable(viewVidget);
    }

    /// Process a `ICP_ImageDrawable` and get a processed one
    /// Params:
    ///   drawable = the drawable to be processed
    /// Returns: processed drawable
    public Result!(Ref!ColorDrawBufEx, ProcessError) process(string imagePath)
    {
        alias ResultType = Result!(Ref!ColorDrawBufEx, ProcessError);
        
        auto icpImage = loadImageFrom(imagePath);
        if(icpImage.hasValue)
        {
            icpImage = selectedPreset.process(icpImage.value);
            return ResultType(createDrawBufFromImage(icpImage.value));
        }

        with(ImageLoadErrorCode)
        final switch(icpImage.error)
        {
            case none:
                throw new Exception("loadImageFrom returned error");
            case corruptedImage:
                return ResultType(ProcessError.corruptedImage);
            case wrongImageFormat:
                return ResultType(ProcessError.wrongImageFormat);
        }
    }

    /// Save `buffer` to the `path`
    /// Params:
    ///   buffer = the buffer 
    ///   path = the file path (including extension)
    public void save(Ref!ColorDrawBufEx buffer, string filePath)
    {
        struct ColorRGBA
        {
            ubyte r, g, b, a;
        }

        union RawColor
        {
            ColorRGBA color;
            int pixel;
        }

        int[] pixels = new int[buffer.width * buffer.height];

        immutable width = buffer.width;
        immutable height = buffer.height;
        
        foreach(y; 0..height)
        {
            int[] line = cast(int[]) buffer.scanLine(y)[0..width];

            foreach(x; 0..width)
            {
                immutable index = y * width + x;
                RawColor color; 
                color.pixel = line[x];
                
                immutable temp = color.color.r;
                color.color.r = color.color.b;
                color.color.b = temp;
                color.color.a = 255;

                // dlangui inverts alfa at some reason :/
                pixels[index] = color.pixel;
            }
        }
        
        ubyte[] channels = cast(ubyte[]) pixels;
        write_image(filePath, buffer.width, buffer.height, channels, ColFmt.RGBA);
    }
}