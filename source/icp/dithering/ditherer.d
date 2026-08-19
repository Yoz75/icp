module icp.dithering.ditherer;
import icp.dithering.iditherer;
import icp.image;
import std.algorithm.comparison : clamp;
import std.math;
/// A dither mask for one pixel
/// ----------
/// // This line means "when processing a pixel and error is not zero, add 40% of the error to the right neighbor"
/// auto mask = DitherMask(0.4, [1, 0]);
/// ----------
public struct DitherMask
{
    float errorMultiplier;
    byte[2] bias;
}

/// Default IDitherer implementation. Fully customizable mask and error multiplier
public class Ditherer : IDitherer
{
    private DitherMask[] masks_;
    /// Cache of the most similar colors for a given color. This is used to speed up the dithering process.

    /// Masks for error propagation.
    public @property void masks(DitherMask[] masks)
    {
        masks_ = masks;
    }
    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// source2DestinationColorMap = associative array, that maps colors from the source image to quanitzed colors
    /// Returns: quantized and dithered image. All colors 
    public Image dither(const Image sourceImage, Color[Color] source2DestinationColorMap)
    {
        Image result = new Image(sourceImage.resolution);

        // [3] because RGB (and we don't dither A)
        int[3][][] accumulatedErrors = new int[3][][](result.resolution[1], result.resolution[0]);

        void applyError(Color quantizedColor, Color correctedSourceColor, size_t sourceX, size_t sourceY)
        {
            foreach(mask; masks_)
            {
                immutable x = sourceX + mask.bias[0];
                immutable y = sourceY + mask.bias[1];

                if(x < 0 || y < 0 || x >= accumulatedErrors[0].length || y >= accumulatedErrors.length)
                {
                    continue;
                }

                ref errors = accumulatedErrors[y][x];

                immutable resultErrorR = cast(int) ((correctedSourceColor.r - quantizedColor.r) * mask.errorMultiplier);
                immutable resultErrorG = cast(int) ((correctedSourceColor.g - quantizedColor.g) * mask.errorMultiplier);
                immutable resultErrorB = cast(int) ((correctedSourceColor.b - quantizedColor.b) * mask.errorMultiplier);

                errors[0] += resultErrorR;
                errors[1] += resultErrorG;
                errors[2] += resultErrorB;
            }
        }

        auto colors = source2DestinationColorMap.values;
        foreach(y; 0..result.resolution[1])
        foreach(x; 0..result.resolution[0])
        {
            immutable sourceColor = sourceImage[x, y];
            immutable int[3] errors = accumulatedErrors[y][x];

            immutable correctedR = cast(ubyte) (sourceColor.r + errors[0]).clamp(0, 255);
            immutable correctedG = cast(ubyte) (sourceColor.g + errors[1]).clamp(0, 255);
            immutable correctedB = cast(ubyte) (sourceColor.b + errors[2]).clamp(0, 255);

            immutable correctedColor = Color(correctedR, correctedG, correctedB);
            immutable quantizedColor = toMostSimilar(correctedColor, colors);
            result[x, y] = quantizedColor;

            applyError(quantizedColor, correctedColor, x, y);
        }

        return result;
    }

    /// Convert color `source` to the most similar one in the `colors`
    /// Params:
    ///   source = the source color
    ///   colors = the array of available colors
    /// Returns: the most similar color in `colors`
    private Color toMostSimilar(Color source, Color[] colors)
    {
        int minTotalDifference = int.max;
        size_t mostSimilarIndex;

        foreach(i, color; colors)
        {
            immutable ubyte differenceR = cast(ubyte) (source.r - color.r).abs;
            immutable ubyte differenceG = cast(ubyte) (source.g - color.g).abs;
            immutable ubyte differenceB = cast(ubyte) (source.b - color.b).abs;
            immutable int totalDifference = differenceR + differenceG + differenceB;
            if(totalDifference < minTotalDifference)
            {
                minTotalDifference = totalDifference;
                mostSimilarIndex = i;            
            }
        }

        return colors[mostSimilarIndex];
    }
} 