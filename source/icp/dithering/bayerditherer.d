module icp.dithering.bayerditherer;

import icp.dithering.iditherer;
import icp.dithering.bayer;
import cereslib.properties;
import cereslib.algorythm;
import std.parallelism : parallel;
import std.range : iota;
import std.algorithm : clamp, sort;
import std.typecons : tuple, Tuple;

/// Uses Bayer matrix to dither the image
/// Params:
///    TPalette = the type of palette to be used
public final class BayerDitherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{
    /// De depth of the bayer matrix
    private @max!uint(14u) uint matrixLevel_ = 1;

    mixin MakeGetter!matrixLevel_;
    mixin MakeSetter!matrixLevel_;

    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// palette = the palette of colors
    /// colors = the handles of palette's colors
    /// Returns: quantized and dithered image
    public Image dither(const Image sourceImage, TPalette palette)
    {
        Bayer bayer = Bayer(matrixLevel_);

        Color[] colors = palette.get;
        immutable mostDifferent = findMostDifferent(colors);
        float[] positions = projectColors1D(colors, mostDifferent[0], mostDifferent[1]);

        auto sorted = sortBoth(colors, positions);
        colors = sorted[0];
        positions = sorted[1];

        Image result = new Image(sourceImage.resolution);

        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            immutable sourcePosition = projectColor1D(sourceColor, mostDifferent[0], mostDifferent[1]);

            /// neighbors of the color on the palette. The lleft and right ones on the 1D axis
            immutable neighborIndices = findNeighborsOf(positions, sourcePosition);
            immutable leftNeighbor = colors[neighborIndices[0]];
            immutable rightNeighbor = colors[neighborIndices[1]];

            immutable leftNeighborPosition = projectColor1D(leftNeighbor, mostDifferent[0], mostDifferent[1]);
            immutable rightNeighborPosition = projectColor1D(rightNeighbor, mostDifferent[0], mostDifferent[1]);

            /// How nearby source position is to left or right position? This is needed because bayer defines threshold
            /// between two colors, not the whole 1d axis
            immutable inetpolatedSourcePos =
                (sourcePosition - leftNeighborPosition)
                / (rightNeighborPosition - leftNeighborPosition);

            immutable threshold = bayer.evaluateNormalized(x % bayer.size, y % bayer.size);

            result[x, y] = inetpolatedSourcePos > threshold ? rightNeighbor : leftNeighbor;
        }

        return result;
    }

    /// Find a pair of two most different colors in the whole slice
    /// Params:
    ///   colors = the colors slice
    /// Returns: two most different colors
    private static Color[2] findMostDifferent(Color[] colors) pure
    {
        return[findColorWithLeastChannelsSum(colors), findColorWithGreatestChannelsSum(colors)];
    }

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
}