module icp.palettes.cachepalette;

import icp.palettes.ipalette;
import cereslib.optional;

/// A wrapper palette that uses associative array to cache searching of the closest color
public final class AACachePalette(T) : IPalette if(is(T : IPalette) && __traits(compiles, {T palette = new T();}))
{
    private enum totalColorsCount = 1 << 24;
    private enum wrongIndex = uint.max;
    private Optional!(Color)[] similarMap;
    private T palette;

    public this()
    {
        palette = new T();
        similarMap = new Optional!(Color)[totalColorsCount];
        similarMap[] = none!(Color);
    }

    /// Get the most similar to `color` Color that palette contains
    /// Params:
    ///    color = the source color
    /// Returns: a color in the palette, most similar to the `color`
    public Color getClosestOnPalette(Color color)
    {
        immutable cacheIndex = (cast(uint) color.r << 16) | (cast(uint) color.g << 8) | color.b;
        immutable cahchedColor = similarMap[cacheIndex];
        if(cahchedColor != none!(Color))
        {
            return cahchedColor.value;
        }

        immutable result = palette.getClosestOnPalette(color);
        similarMap[cacheIndex] = result;

        return result;
    }

    /// Map `sourceColor` to `paletteColor` and add `paletteColor` to the palette
    /// Params:
    ///   sourceColor = the color to be mapped
    ///   paletteColor = the color to be added to the palette and mapped to the sourceColor
    public void add(Color color)
    {
        return palette.add(color);
    }
    
    /// Get the palette
    /// Returns: slice of all colors in the palette
    public inout(Color[]) get() inout
    {
        return palette.get();
    }
}