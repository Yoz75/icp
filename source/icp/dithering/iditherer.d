module icp.dithering.iditherer;
import icp.image;

/*
/// A map that converts 
public struct QuantizationMap
{
    invariant
    {
        rawColors.length == quantizedColors.length;
    }

    private Color[] rawColors;
    private Color[] quantizedColors;
}
*/
public interface IDitherer
{
    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// source2DestinationColorMap = associative array, that maps colors from the source image to quanitzed colors
    /// Returns: quantized and dithered image. All colors 
    public Image dither(const Image sourceImage, Color[Color] source2DestinationColorMap);
}