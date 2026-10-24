module icp.dithering.bayerditherer;

import icp.dithering.bayer;
import icp.dithering.pditherer;
import cereslib.properties;
import cereslib.algorythm;
import std.parallelism : parallel;
import std.range : iota;
import std.algorithm : clamp, sort, mean;

/// Uses Bayer matrix to dither the image
/// Params:
///    TPalette = the type of palette to be used
public final class BayerDitherer(TPalette) : ProjectedDitherer!TPalette if(is(TPalette : IPalette))
{
    /// Should we use old algorythm?
    public bool useOldBayer;

    /// De depth of the bayer matrix
    private @max!uint(14u) uint matrixLevel_ = 1;
    private @min!float(-100) @max!float(100) float strength_ = 0.5f;

    mixin MakeGetter!matrixLevel_;
    mixin MakeSetter!matrixLevel_;

    mixin MakeGetter!strength_;
    mixin MakeSetter!strength_;

    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// palette = the palette of colors
    /// colors = the handles of palette's colors
    /// Returns: quantized and dithered image
    protected  override Image dither(const Image sourceImage, TPalette palette, Color[] colors, float[] positions)
    {
        Image result = new Image(sourceImage.resolution);

        if(useOldBayer)
        {
            oldBayer(sourceImage, result, colors, positions);
        }
        else
        {
            newBayer(sourceImage, result, colors, positions);
        }

        return result;
    }

    private void newBayer(const Image sourceImage, Image result, Color[] colors, float[] positions)
    {
        Bayer bayer = Bayer(matrixLevel_);

        // cuz they are sorted like positions
        immutable leastColor = colors[0];
        immutable greatestColor = colors[$ - 1];

        immutable offset = positions.mean() * strength_;
        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            immutable sourcePosition = projectColor1D(sourceColor, leastColor, greatestColor);

            immutable threshold = bayer.evaluateNormalized(x % bayer.size, y % bayer.size);
            immutable newPosition = sourcePosition + offset * (threshold - 0.5f);

            immutable resultColor = colors[positions.findIndexOfNearest(newPosition)];
            result[x, y] = resultColor;
        }
    }

    private void oldBayer(const Image sourceImage, Image result, Color[] colors, float[] positions)
    {
        Bayer bayer = Bayer(matrixLevel_);

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
    }
}