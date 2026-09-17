module icp.dithering.randomditherer;

import icp.dithering.iditherer;
import cereslib.math;
import std.meta : AliasSeq;
import std.random;
import std.parallelism : parallel;
import std.range : iota;

/// Using random to dither the image
public final class RandomDitherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{    
    private float spreading_ = 0.5f;

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
        
        float[] positions = projectColors1D(colors, least, greatest);

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
    private Color[2] findMostDifferent(Color[] colors) pure
    {
        return[min(colors), max(colors)];
    }

    /// Find "minimal" color in the array (the color with the least sum of channels)
    /// Params:
    ///   colors = the slice of colors
    /// Returns: the "least" color
    private Color min(Color[] colors) pure
    {
        size_t leastIndex = 0;
        int leastChannelsSum = int.max;

        foreach(i, color; colors)
        {
            immutable sum = color.r + color.g + color.b;
            
            if(sum < leastChannelsSum)
            {
                leastChannelsSum = sum;
                leastIndex = i;
            }
        }

        return colors[leastIndex];
    }

    /// Find "maximal" color in the array (the color with the least sum of channels)
    /// Params:
    ///   colors = the slice of colors
    /// Returns: the "greatest" color
    private Color max(Color[] colors) pure
    {
        size_t greatestIndex = 0;
        int greatestChannelsSum = int.min;

        foreach(i, color; colors)
        {
            immutable sum = color.r + color.g + color.b;
            
            if(sum > greatestChannelsSum)
            {
                greatestChannelsSum = sum;
                greatestIndex = i;
            }
        }

        return colors[greatestIndex];
    }

    /// Get index of most similar to `value` element of `sortedArray`
    /// Params:
    ///   sortedArray = the array of all values
    ///   value = the target value
    /// Returns: index of most similar value or size_t.max
    private size_t findIndexOfNearest(float[] positions, float targetPosition) pure
    {
        import std.math : abs;

        if (positions.length == 0)
            return size_t.max;

        size_t nearestIndex = 0;
        float nearestDistance = abs(positions[0] - targetPosition);

        foreach (index, position; positions[1 .. $])
        {
            immutable distance = abs(position - targetPosition);

            if (distance < nearestDistance)
            {
                nearestDistance = distance;
                nearestIndex = index + 1;
            }
        }

        return nearestIndex;
    }
}