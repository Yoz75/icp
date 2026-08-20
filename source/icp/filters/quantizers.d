module icp.filters.quantizers;

import icp.image;
import icp.filters.ifilter;
import icp.dithering;
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

/// Quantizes colors using median section algorythm
public final class MedianSectionFilter : IFilter
{
    /// The total count of colors in the result image
    public uint colorsCount = 8;

    /// Should we slightly correct colors for better perception? (https://habr.com/ru/articles/304210/)
    public bool useColorCorrection;

    private float redCorrectionMultiplier_ = 0.2126f;
    private float greenCorrectionMultiplier_ = 0.7152;
    private float blueCorrectionMultiplier_ = 0.0722;

    private IDitherer ditherer_;

    public this()
    {
        ditherer_ = new NoDitherer();
    }

    public @property void ditherer(IDitherer ditherer)
    {
        if(ditherer is null)
        {
            ditherer_ = new NoDitherer();
            return;
        }

        ditherer_ = ditherer;
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

    public Image filter(const Image image)
    {
        auto registeredColors = registerColors(image);
        if(registeredColors.length <= colorsCount)
        {
            return image.dup;
        }

        auto quantizedMap = quantize(registeredColors, colorsCount);

        return ditherer_.dither(image, quantizedMap);
    }

    /// Quantize colors of the image and return a map of colors to their meta info
    /// Params:
    ///   image = 
    /// Returns: registered colors mapped to it's quantized variants. Assumes you'll map ONLY REGISTERED colors
    private Color[Color] quantize(ColorMetaInfo[Color] registeredColors, uint colorsCount)
    {
        // a kostyl to make it work
        Color[Color] mappedColors;
        // This shit calculates medium color and maps colors in the slice to it
        void mapColorsIn(ColorMetaInfo[] slice)
        {
            uint mediumR, mediumG, mediumB;
            uint totalColorsCount;

            foreach(metaInfo; slice)
            {
                mediumR += metaInfo.color.r * metaInfo.appearances;
                mediumG += metaInfo.color.g * metaInfo.appearances;
                mediumB += metaInfo.color.b * metaInfo.appearances;

                totalColorsCount += metaInfo.appearances;
            }

            mediumR /= totalColorsCount;
            mediumG /= totalColorsCount;
            mediumB /= totalColorsCount;
            Color mediumColor = Color(cast(ubyte) mediumR, cast(ubyte) mediumG, cast(ubyte) mediumB);
            foreach(metaInfo; slice)
            {
                Color* mappedColor = metaInfo.color in mappedColors;
                if(mappedColor is null)
                {
                    mappedColors[metaInfo.color] = mediumColor;
                }
            }
        }

        ColorMetaInfo[] quantizedColors = registeredColors.byValue.array;

        immutable float[3] rgbMultipliers = 
        useColorCorrection ? [redCorrectionMultiplier_, greenCorrectionMultiplier_, blueCorrectionMultiplier_]
                           : [1f, 1f, 1f];

        recursiveAction!sortByChannel(quantizedColors, colorsCount, rgbMultipliers);
        forEachSubArray!mapColorsIn(quantizedColors, colorsCount);

        return mappedColors;
    }
}

/*
    I had to separate these functions cuz of "double context"
*/

/// Register all unique colors and their appearances in the image and return a map of colors to their meta info
/// Params:
///   image = 
/// Returns: associative array of colors to their meta info
private ColorMetaInfo[Color] registerColors(const Image image) pure
{
    uint totalColorsCount;
    ColorMetaInfo[Color] registeredColors;
    foreach(y; 0..image.resolution[1])
    foreach(x; 0..image.resolution[0])
    {
        Color currentColor = image[x, y];
        ColorMetaInfo* registeredColor = currentColor in registeredColors;
        if(registeredColor is null)
        {
            registeredColors[currentColor] = ColorMetaInfo(currentColor, 1);
            totalColorsCount++;
        }
        else
        {
            registeredColor.appearances++;
        }
    }
    return registeredColors;
}



/// Perfom `action` on the input array, then on its halves, then quarters, etc
/// Params:
///   colors = the array
///   targetSubarrayCount = the count of subarrays on the last layer
///   params = additional parameters of the function
private void recursiveAction(alias action, T...)(ColorMetaInfo[] colors, size_t targetSubarrayCount, T params) pure
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
private void forEachSubArray(alias action, T...)(ColorMetaInfo[] colors, size_t subArraysCount, T params)
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
private void sortByChannel(ColorMetaInfo[] input, float[3] rgbCorrection) pure
{
    static bool isLessR(ColorMetaInfo a, ColorMetaInfo b) => a.color.r < b.color.r;
    static bool isLessG(ColorMetaInfo a, ColorMetaInfo b) => a.color.g < b.color.g;
    static bool isLessB(ColorMetaInfo a, ColorMetaInfo b) => a.color.b < b.color.b;

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
private ColorChannel findChannelWithMostGap(scope ColorMetaInfo[] slice, float[3] rgbCorrection) pure
{
    import std.algorithm.comparison : min, max;

    ubyte minR = 255, maxR = 0;
    ubyte minG = 255, maxG = 0;
    ubyte minB = 255, maxB = 0;

    foreach(color; slice)
    {
        minR = min(color.color.r, minR);
        maxR = max(color.color.r, maxR);
        minG = min(color.color.g, minG);
        maxG = max(color.color.g, maxG);
        minB = min(color.color.b, minB);
        maxB = max(color.color.b, maxB);
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