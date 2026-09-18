module icp.dithering.bayerditherer;

import icp.dithering.iditherer;
import icp.dithering.bayer;
import cereslib.properties;
import cereslib.algorythm;
import std.parallelism : parallel;
import std.range : iota;
import std.algorithm : clamp;

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

        Color[] paletteColors = palette.get;
        immutable mostDifferent = findMostDifferent(paletteColors);
        immutable float[] palettePositions = projectColors1D(paletteColors, mostDifferent[0], mostDifferent[1]);

        /*
            алгоритм:
            1) найти для цвета в сорсе 2 соседних цвета на палитре
            2) если позиция левого + (байер - 0.5) > 0,5, то берём правый, иначе левый
        */

        Image result = new Image(sourceImage.resolution);

        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            immutable sourcePosition = projectColor1D(sourceColor, mostDifferent[0], mostDifferent[1]);

            /// neighbors of the color on the palette. The lleft and right ones on the 1D axis
            immutable neighbors = findNearestIndexTo(palettePositions, sourcePosition);

            /// How nearby source position is to left or right position? This is needed because bayer defines threshold
            /// between two colors, not the whole 1d axis
            immutable inetpolatedSourcePos =
                (sourcePosition - palettePositions[$-1])
                / (palettePositions[0] - palettePositions[$-1]);

            immutable threshold = bayer.evaluateNormalized(x % bayer.size, y % bayer.size);

            result[x, y] = inetpolatedSourcePos < threshold ? paletteColors[neighbors[0]] : paletteColors[neighbors[1]];
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
}