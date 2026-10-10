module icp.dithering.randomditherer;

import icp.dithering.iditherer;
import cereslib.math;
import cereslib.algorythm;
import cereslib.properties;
import std.meta : AliasSeq;
import std.random;
import std.parallelism : parallel;
import std.range : iota;

/// Using random to dither the image
public final class RandomDitherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{    
    private alias cpmin = cereslib.properties.min;
    private alias cpmax = cereslib.properties.max;

    private @cpmin!float(0) @cpmax!float(float.infinity) float spreading_ = 0.5f;

    mixin MakeGetter!spreading_;
    mixin MakeSetter!spreading_;

    public @property float spreading() => spreading_;
    public @property void spreading(float value)
    {
        if(value == float.nan || value == float.infinity  || value == -float.infinity)
        {
            throw new Exception("Random ditherer got non-finite value!");
        }

        spreading_ = value;
    }

    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// palette = the palette of colors
    /// colors = the handles of palette's colors
    /// Returns: quantized and dithered image
    public Image dither(const Image sourceImage, TPalette palette)
    {
        Color[] colors = palette.get();

        /// map of  indexes of color in `colors` array
        ulong[] color2colorsIndex = new ulong[2 ^^ 24];
        /// value of color that is NOT in `colors`
        enum wrongIndex = uint.max;

        color2colorsIndex[] = wrongIndex;

        immutable mostDifferent = findMostDifferent(colors);
        immutable least = mostDifferent[0];
        immutable greatest = mostDifferent[1];
        
        immutable float[] positions = projectColors1D(colors, least, greatest);

        Image result = new Image(sourceImage.resolution);

        /*
        
            See BayerDitherer
        
        */
        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            immutable sourcePosition = projectColor1D(sourceColor, mostDifferent[0], mostDifferent[1]);

            immutable neighborIndices = findNeighborsOf(positions, sourcePosition);
            immutable leftNeighbor = colors[neighborIndices[0]];
            immutable rightNeighbor = colors[neighborIndices[1]];

            immutable leftNeighborPosition = projectColor1D(leftNeighbor, mostDifferent[0], mostDifferent[1]);
            immutable rightNeighborPosition = projectColor1D(rightNeighbor, mostDifferent[0], mostDifferent[1]);

            immutable inetpolatedSourcePos =
                (sourcePosition - leftNeighborPosition)
                / (rightNeighborPosition - leftNeighborPosition);

            immutable threshold = spreading_ * (uniform01() * 2 - 1);
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
}