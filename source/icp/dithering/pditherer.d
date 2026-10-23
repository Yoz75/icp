module icp.dithering.pditherer;

public import icp.dithering.iditherer;
import std.typecons : tuple, Tuple;
import std.algorithm;

/// A ditherer that projects colors on a 1D axis
public abstract class ProjectedDitherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{
    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// palette = the palette of colors
    /// colors = the handles of palette's colors
    /// Returns: quantized and dithered image
    public Image dither(const Image sourceImage, TPalette palette)
    {
        Color[] colors = palette.get;
        immutable mostDifferent = findMostDifferent(colors);
        float[] positions = projectColors1D(colors, mostDifferent[0], mostDifferent[1]);

        auto sorted = sortBoth(colors, positions);
        colors = sorted[0];
        positions = sorted[1];

        return dither(sourceImage, palette, colors, positions);
    }

    protected abstract Image dither(const Image image, TPalette palette, Color[] colors, float[] positions);

    // it's pretty messy, but we use this function ONCE per run so whatever
    private static Tuple!(Color[], float[]) sortBoth(Color[] colors, float[] positions)
    {
        size_t[] indices = new size_t[positions.length];
        foreach (size_t index, ref size_t value; indices)
            value = index;

        indices.sort!((a, b) => positions[a] < positions[b]);

        float[] sortedPositions = new float[positions.length];
        Color[] sortedColors = new Color[colors.length];

        foreach (size_t sortedIndex, originalIndex; indices)
        {
            sortedPositions[sortedIndex] = positions[originalIndex];
            sortedColors[sortedIndex] = colors[originalIndex];
        }

        return tuple(sortedColors, sortedPositions);
    }

    /// Find a pair of two most different colors in the whole slice
    /// Params:
    ///   colors = the colors slice
    /// Returns: two most different colors
    private static Color[2] findMostDifferent(Color[] colors) pure
    {
        return[findColorWithLeastChannelsSum(colors), findColorWithGreatestChannelsSum(colors)];
    }
}