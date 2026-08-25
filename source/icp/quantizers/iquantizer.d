module icp.quantizers.iquantizer;

public import icp.palettes.ipalette;
public import icp.image;

public interface IQuantizer(TPalette) if(is(TPalette : IPalette))
{
    /// Create a palette from iamge with `colorsCount` colors
    /// Params:
    ///   image = the image to grab colors
    ///   colorsCount = the result count of colors in the palette
    /// Returns: a new palette
    public TPalette quantize(const(Image) image);
}