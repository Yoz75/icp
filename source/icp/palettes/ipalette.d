module icp.palettes.ipalette;

import icp.color;

/// A finite range of colors
public interface IPalette
{
    /// Get the most similar to `color` Color that palette contains
    public Color getClosestOnPalette(Color color);

    /// Add a color to the palette
    public void addToPalette(Color color);
}