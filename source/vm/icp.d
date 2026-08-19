module vm.icp;

import vm.presets;
import view.memorydrawable;
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
        /// No error!
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
    public SumType!(ColorDrawBuf, ProcessError) process(string imagePath)
    {
        alias Result = SumType!(ColorDrawBuf, ProcessError);

        IFImage loadedImage;
        try
        {
            loadedImage = read_image(imagePath);
        }
        catch(ImageIOException)
        {
            return Result(ProcessError.corruptedImage);
        }
        
        if(loadedImage.c != ColFmt.RGBA && loadedImage.c != ColFmt.RGB)
        {
            return Result(ProcessError.wrongImageFormat);
        }

        Image icpImage = new Image([loadedImage.w, loadedImage.h]);

        /*
            OH NO!!!1! CODE DUPLICATION11111!!11!
        */
        if(loadedImage.c == ColFmt.RGBA)
        {
            enum colorSize = 4;
            foreach(int y; 0..icpImage.resolution[1])
            foreach(int x; 0..icpImage.resolution[0])
            {
                immutable index = (y * icpImage.resolution[0] + x) * colorSize;
                immutable icp.color.Color color =
                icp.color.Color(loadedImage.pixels[index],
                    loadedImage.pixels[index + 1],
                    loadedImage.pixels[index + 2],
                    loadedImage.pixels[index + 3]);

                icpImage[x, y] = color;
            }
        }
        else
        {
            enum colorSize = 3;
            foreach(int y; 0..icpImage.resolution[1])
            foreach(int x; 0..icpImage.resolution[0])
            {
                immutable index = (y * icpImage.resolution[0] + x) * colorSize;
                immutable icp.color.Color color =
                icp.color.Color(loadedImage.pixels[index],
                    loadedImage.pixels[index + 1],
                    loadedImage.pixels[index + 2], 
                    255);

                icpImage[x, y] = color;
            }
        }

        icpImage = selectedPreset.process(icpImage);

        Result result = createDrawBufFromImage(icpImage);
        return result;
    }
}

/// Create a draw buf from image
/// Params:
///   image = the icp image
/// Returns: a new ColorDrawBuf
public ColorDrawBuf createDrawBufFromImage(Image image)
{
    /// ARGB but reversed (probably cuz little endian??? Idk but dlangui accepts BGRA)
    struct ColorBGRA
    {
        ubyte b, g, r, a;
    }

    int[2] resolution = [cast(int) image.resolution[0], cast(int) image.resolution[1]];
    ColorDrawBuf drawBuf = new ColorDrawBuf(resolution[0], resolution[1]);
    
    foreach(y; 0..resolution[1])
    {
        uint* linePtr = drawBuf.scanLine(y);

        // this line says "assume this pointer is a slice of length resolution[0]"
        ColorBGRA[] line = (cast(ColorBGRA*) linePtr)[0..resolution[0]];

        // we assume line.length < int.max cuz a 2 millin by 2 million texture is a nonsense
        foreach(int x; 0.. cast(int) line.length)
        {
            // Source contains RGBA color and we need ARGB so we swap B and A
            // (cuz RGBA's A is ARGB's B)
            immutable colorRGBA = image[x, y];

            /// at some reason dlangui thinks that alfa 0 is opaque and alfa 255 is transparent
            immutable colorARGB = ColorBGRA(colorRGBA.b, colorRGBA.g, colorRGBA.r, 255 - colorRGBA.a);

            line[x] = colorARGB;
        }
    }

    return drawBuf;
}