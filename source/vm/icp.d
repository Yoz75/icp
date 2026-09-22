module vm.icp;

import vm.presets;
import vm.image;
import view;
import icp.color;
import icp.image;
import icp.filters;
import std.sumtype;
import std.algorithm : remove, endsWith;
import std.string : strip, splitLines;
import imageformats;
import dlangui;

/// ICP view model
public final class ICP_VM
{
    private Preset selectedPreset;

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
    public Result!(Ref!ColorDrawBufEx, string) process(string imagePath)
    {
        alias ResultType = Result!(Ref!ColorDrawBufEx, string);
        
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
                return ResultType("ICP_VM_corruptedImageError");
            case wrongImageFormat:
                return ResultType("ICP_VM_wrongImageFormatError");
        }
    }

    /// Save `buffer` to the `path`
    /// Params:
    ///   buffer = the buffer 
    ///   path = the file path (including extension)
    public void save(Ref!ColorDrawBufEx buffer, string filePath)
    {
        Image icpImage = createImageFromDrawBuf(buffer);
        saveTrueColorImageTo(filePath, icpImage);
    }
}