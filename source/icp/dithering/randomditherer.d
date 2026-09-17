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
        Color[] colors = findColors(sourceImage);

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

        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            immutable sourceColor = sourceImage[x, y];
            auto ref cachedIndex = color2colorsIndex[sourceColor.value];
            
            if(cachedIndex == wrongIndex)
            {
                cachedIndex = colors.getIndexOfMostSimilar!manhattanDistance(sourceColor);
            }

            // since elements in colors, and color2position have same locations,, we can use this index in both arrays
            immutable selectedColorIndex = cachedIndex;

            immutable randomFactor =  uniform01() * 2f - 1;
            immutable selectedPosition = positions[selectedColorIndex] + spreading_ * randomFactor;
            immutable bestColorIndex = findIndexOfNearest(positions, selectedPosition);
            assert(bestColorIndex != size_t.max, "could not find the best index!");
            
            result[x, y] = palette.getClosestOnPalette(colors[bestColorIndex]);
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