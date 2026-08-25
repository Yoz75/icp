module icp.quantizers.mediansection;

import icp.quantizers.iquantizer;
import std.algorithm.sorting;
import std.range;

private struct ColorMetaInfo
{
public:
    Color color;
    uint appearances;
}

private enum ColorChannel : ubyte
{
    r,
    g,
    b
}

public final class MedianSectionQuantizer(TPalette) : IQuantizer!TPalette if(is(TPalette : IPalette))
{
    /// Should we slightly correct colors for better perception? (https://habr.com/ru/articles/304210/)
    public bool useColorCorrection;
    /// Target colors count in the palette
    public uint colorsCount = 8;
    
    private float redCorrectionMultiplier_ = 0.2126f;
    private float greenCorrectionMultiplier_ = 0.7152;
    private float blueCorrectionMultiplier_ = 0.0722;

    invariant
    {
        assert(colorsCount > 0);
    }

    public @property void redCorrectionMultiplier(float value)
    {
        redCorrectionMultiplier_ = value;
    }

    public @property void greenCorrectionMultiplier(float value)
    {
        greenCorrectionMultiplier_ = value;
    }

    public @property void blueCorrectionMultiplier(float value)
    {
        blueCorrectionMultiplier_ = value;
    }

    /// Create a palette from iamge with `colorsCount` colors
    /// Params:
    ///   image = the image to grab colors
    ///   colorsCount = the result count of colors in the palette
    /// Returns: a new palette
    public TPalette quantize(const(Image) image)
    {
        uint[] appearances;
        Color[] colors = findColors(image, appearances);
        return quantize(colors, appearances);
    }

    /// Quantize colors of the image and return a map of colors to their meta info
    /// Params:
    ///   image = 
    /// Returns: registered colors mapped to it's quantized variants. Assumes you'll map ONLY REGISTERED colors
    private TPalette quantize(Color[] registeredColors, uint[] appearances)
    {
        TPalette palette = new TPalette();

        // This shit calculates medium color and maps colors in the slice to it
        void mapColorsIn(Color[] slice)
        {
            uint mediumR, mediumG, mediumB;
            uint totalColorsCount;

            immutable sliceIndex = registeredColors.getSubArrayStartIndex(slice);
            foreach(color; slice)
            {
                immutable appearance = appearances[sliceIndex];
                mediumR += color.r * appearance;
                mediumG += color.g * appearance;
                mediumB += color.b * appearance;

                totalColorsCount += appearance;
            }

            mediumR /= totalColorsCount;
            mediumG /= totalColorsCount;
            mediumB /= totalColorsCount;
            Color mediumColor = Color(cast(ubyte) mediumR, cast(ubyte) mediumG, cast(ubyte) mediumB);
            foreach(color; slice)
            {
                if(!palette.has(color))
                {
                    palette.add(color, mediumColor);
                }
            }
        }

        immutable float[3] rgbMultipliers = 
        useColorCorrection ? [redCorrectionMultiplier_, greenCorrectionMultiplier_, blueCorrectionMultiplier_]
                           : [1f, 1f, 1f];

        recursiveAction!sortByChannel(registeredColors, colorsCount, rgbMultipliers);
        forEachSubArray!mapColorsIn(registeredColors, colorsCount);

        return palette;
    }
}

// very lowlevel thyng -_-
/// If `subArray` is a slice of `superArray`, returns index in `superArray` of the first element of `subArray`. suze_t.max otherwise
/// Params:
///   superArray = the array
///   subarray = the slice of `superArray`
/// Returns: index in `superArray` or size_t.max if `subArray` isn't a slice of `superArray`
private size_t getSubArrayStartIndex(T)(in T[] superArray, in T[] subArray) @system pure
{
    enum size = T.sizeof;
    const T* superPtr = superArray.ptr;
    const T* subPtr = subArray.ptr;

    if(!superArray.isInsideBounds(subArray))
    {
        return size_t.max;
    }

    immutable distance = subPtr - superPtr;

    return distance / size;
}

/// Returns true if `subArray` is inside bounds of `superArray` (i.e a slice of `superArray`), false otherwise
/// Params:
///   superArray = the array
///   subarray = the slice of the `superArray`
/// Returns: true if `subArray` is inside bounds of `superArray` (i.e a slice of `superArray`), false otherwise
private bool isInsideBounds(T)(in T[] superArray, in T[] subArray) pure
{
    immutable byteSuperLength = superArray.length * T.sizeof;
    return superArray.ptr <= subArray.ptr && subArray.ptr < (superArray.ptr + byteSuperLength);
}


/*
    I had to separate these functions cuz of "double context"
*/

/// Perfom `action` on the input array, then on its halves, then quarters, etc
/// Params:
///   colors = the array
///   targetSubarrayCount = the count of subarrays on the last layer
///   params = additional parameters of the function
private void recursiveAction(alias action, T...)(Color[] colors, size_t targetSubarrayCount, T params) pure
{
    size_t subarraysCount = 1;
    while (subarraysCount <= targetSubarrayCount)
    {
        forEachSubArray!action(colors, subarraysCount, params);
        /*for (size_t subarrayIndex = 0; subarrayIndex < subarraysCount; ++subarrayIndex)
        {
            size_t begin = colors.length * subarrayIndex / subarraysCount;
            size_t end = colors.length * (subarrayIndex + 1) / subarraysCount;
            action(colors[begin .. end]);
        }*/
        subarraysCount *= 2;
    }
}
/// Perform `action` for each subarray in `colors`
/// Params:
///   colors = the array
///   subArraysCount = the count of subarrays
///   params = additional parameters of the function
private void forEachSubArray(alias action, T...)(Color[] colors, size_t subArraysCount, T params)
{
    for (size_t subarrayIndex = 0; subarrayIndex < subArraysCount; ++subarrayIndex)
    {
        size_t begin = colors.length * subarrayIndex / subArraysCount;
        size_t end = colors.length * (subarrayIndex + 1) / subArraysCount;
        action(colors[begin .. end], params);
    }
}
/// Sort the input array by widest color channel
/// Params:
///   input = the in[ut array]
private void sortByChannel(Color[] input, float[3] rgbCorrection) pure
{
    static bool isLessR(Color a, Color b) => a.r < b.r;
    static bool isLessG(Color a, Color b) => a.g < b.g;
    static bool isLessB(Color a, Color b) => a.b < b.b;

    immutable channelWithMostGap = findChannelWithMostGap(input, rgbCorrection);
    final switch(channelWithMostGap)
    {
        case ColorChannel.r: input.sort!isLessR; break;
        case ColorChannel.g: input.sort!isLessG; break;
        case ColorChannel.b: input.sort!isLessB; break;
    }
}
/// Find the color channel with the biggest gap (i.e biggest difference between min and max)
/// Returns: 
private ColorChannel findChannelWithMostGap(return scope Color[] slice, float[3] rgbCorrection) pure
{
    import std.algorithm.comparison : min, max;

    ubyte minR = 255, maxR = 0;
    ubyte minG = 255, maxG = 0;
    ubyte minB = 255, maxB = 0;

    foreach(color; slice)
    {
        minR = min(color.r, minR);
        maxR = max(color.r, maxR);
        minG = min(color.g, minG);
        maxG = max(color.g, maxG);
        minB = min(color.b, minB);
        maxB = max(color.b, maxB);
    }

    immutable differenceR = cast(ubyte) ((maxR - minR) * rgbCorrection[0]);
    immutable differenceG = cast(ubyte) ((maxG - minG) * rgbCorrection[1]);
    immutable differenceB = cast(ubyte) ((maxB - minB) * rgbCorrection[2]);
    
    immutable maximalDifference = max(differenceR, differenceG, differenceB);
    switch(maximalDifference)
    {
        case differenceR: return ColorChannel.r;
        case differenceG: return ColorChannel.g;
        case differenceB: return ColorChannel.b;
        default: throw new Exception("Minimal difference is not equals to any difference of a channel!
         Our math doesn't work!");
    }
}