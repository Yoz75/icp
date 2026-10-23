module icp.dithering.bayerditherer;

import icp.dithering.bayer;
import icp.dithering.pditherer;
import cereslib.properties;
import cereslib.algorythm;
import std.parallelism : parallel;
import std.range : iota;
import std.algorithm : clamp, sort;

/// Uses Bayer matrix to dither the image
/// Params:
///    TPalette = the type of palette to be used
public final class BayerDitherer(TPalette) : ProjectedDitherer!TPalette if(is(TPalette : IPalette))
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
    protected  override Image dither(const Image sourceImage, TPalette palette, Color[] colors, float[] positions)
    {
        Bayer bayer = Bayer(matrixLevel_);
        Image result = new Image(sourceImage.resolution);

        // cuz they are sorted like positions
        immutable leastColor = colors[0];
        immutable greatestColor = colors[$ - 1];

        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            immutable sourcePosition = projectColor1D(sourceColor, leastColor, greatestColor);

            /// neighbors of the color on the palette. The lleft and right ones on the 1D axis
            immutable neighborIndices = findNeighborsOf(positions, sourcePosition);
            immutable leftNeighbor = colors[neighborIndices[0]];
            immutable rightNeighbor = colors[neighborIndices[1]];

            immutable leftNeighborPosition = projectColor1D(leftNeighbor, leastColor, greatestColor);
            immutable rightNeighborPosition = projectColor1D(rightNeighbor, leastColor, greatestColor);

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
}