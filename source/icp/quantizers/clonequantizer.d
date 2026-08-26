module icp.quantizers.clonequantizer;

import icp.quantizers.iquantizer;

/// Clones palette from an image
public final class CloneQuantizer(TPalette) : IQuantizer!TPalette if(is(TPalette : IPalette))
{
    private Image sourceImage_;

    /// The image that provides palette
    /// Params:
    ///   image = 
    public @property void sourceImage(Image image)
    {
        sourceImage_ = image;
    }

    /// Create a palette from iamge with `colorsCount` colors
    /// Params:
    ///   image = the image to grab colors
    ///   colorsCount = the result count of colors in the palette
    /// Returns: a new palette
    public TPalette quantize(const(Image) image)
    {
        Color[] colors = findColors(sourceImage_);

        TPalette palette = new TPalette();

        foreach(color; colors)
        {
            palette.add(color);
        }

        return palette;
    }
}