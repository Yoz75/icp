module icp.palettes.linearsearchpalette;

import icp.palettes.ipalette;

/// Palette that linearly searches the most close color
public final class LinearSearchPalette : IPalette
{
    private Color[Color] palette;
    private Color[] values;
    private uint valuesGeneration, lastValuesGeneration;

    /// Get the most similar to `color` Color that palette contains
    /// Params:
    ///    color = the source color
    /// Returns: a color in the palette, most similar to the `color`
    public Color getClosestOnPalette(Color color)
    {
        if(valuesGeneration != lastValuesGeneration)
        {
            destroy(values);
            values = palette.values;
            lastValuesGeneration = valuesGeneration;
        }

        int minDistance = int.max;
        Color mostSimilarColor;

        foreach(found; values)
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
    public void add(Color sourceColor, Color paletteColor)
    {
        palette[sourceColor] = paletteColor;
        valuesGeneration++;
    }

    /// Get mapped to the `color`` in the palette. Assumes `color` is already added
    /// Params:
    ///   handle = the handle
    /// Returns: mapped color
    public Color map(Color color)
    {
        return palette[color];
    }

    /// Does the palette has `color`?
    /// Params:
    ///   color = the color
    /// Returns: true if has and false otherwise
    public bool has(Color color)
    {
        auto colorPtr = color in palette;

        return colorPtr !is null;
    }
}