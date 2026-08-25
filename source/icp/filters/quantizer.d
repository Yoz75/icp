module icp.filters.quantizer;

import icp.filtreg;
import icp.filters.ifilter;
import icp.quantizers;
import icp.dithering;
import icp.palettes;

// Some alternative to polymorphysm
public alias Palette = AACachePalette!LinearSearchPalette;
public alias DefaultQuantizer = IQuantizer!Palette;
public alias DefaultDitherer = IDitherer!Palette;

/// Filter that glues together some IQuantizer and IDitherer. Allows you to quantize and possibly dither an image;
public @filter final class QuantizeFilter : IFilter
{
    public DefaultQuantizer quantizer;
    public DefaultDitherer ditherer;

    public this()
    {
        quantizer = new MedianSectionQuantizer!Palette();
        ditherer = new NoDitherer!Palette();
    }

    public Image filter(const(Image) image)
    {
        return ditherer.dither(image, quantizer.quantize(image));
    }
} 