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
    public void add(Color sourceColor, Color paletteColor);

    /// Get mapped to the `color`` in the palette. Assumes `color` is already added
    /// Params:
    ///   handle = the handle
    /// Returns: mapped color
    public Color map(Color color);

    /// Does the palette has `color`?
    /// Params:
    ///   color = the color
    /// Returns: true if has and false otherwise
    public bool has(Color color);
}