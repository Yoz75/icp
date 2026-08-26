module icp.palettes.ipalette;

public import icp.color;

/// A finite range of colors
public interface IPalette
{
    /// Get the most similar to `color` Color that palette contains
    /// Params:
    ///    color = the source color
    /// Returns: a color in the palette, most similar to the `color`
    public Color getClosestOnPalette(Color color);

    /// Map `sourceColor` to `paletteColor` and add `paletteColor` to the palette
    /// Params:
    ///   sourceColor = the color to be mapped
    ///   paletteColor = the color to be added to the palette and mapped to the sourceColor
    public void add(Color color);

    /// Get the palette
    /// Returns: slice of all colors in the palette
    public inout(Color[]) get() inout;
}