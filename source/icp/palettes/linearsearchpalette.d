module icp.palettes.linearsearchpalette;

import icp.palettes.ipalette;

/// Palette that linearly searches the most close color
public final class LinearSearchPalette : IPalette
{
    private Color[] palette;

    /// Get the most similar to `color` Color that palette contains
    /// Params:
    ///    color = the source color
    /// Returns: a color in the palette, most similar to the `color`
    public Color getClosestOnPalette(Color color)
    {
        int minDistance = int.max;
        Color mostSimilarColor;

        foreach(found; palette)
        {
            immutable distance = manhattanDistance(color, found);

            if(distance < minDistance)
            {
                minDistance = distance;
                mostSimilarColor = found;            
            }
        }

        return mostSimilarColor;
    }

    /// Map `sourceColor` to `paletteColor` and add `paletteColor` to the palette
    /// Params:
    ///   sourceColor = the color to be mapped
    ///   paletteColor = the color to be added to the palette and mapped to the sourceColor
    public void add(Color color)
    {
        palette ~= color;
    }

    /// Get the palette
    /// Returns: slice of all colors in the palette
    public inout(Color[]) get() inout
    {
        return palette;
    }
}