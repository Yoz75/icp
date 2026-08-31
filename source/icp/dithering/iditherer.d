module icp.dithering.iditherer;
public import icp.image;
public import icp.palettes;

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
public interface IDitherer (TPalette) if(is(TPalette : IPalette))
{
    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// palette = the palette of colors
    /// colors = the handles of palette's colors
    /// Returns: quantized and dithered image
    public Image dither(const Image sourceImage, TPalette palette);
}