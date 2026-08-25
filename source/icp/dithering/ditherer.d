module icp.dithering.ditherer;
import icp.dithering.iditherer;
import icp.image;
import icp.palettes;
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
public class Ditherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{
    private DitherMask[] masks_;

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
    public Image dither(const Image sourceImage, TPalette palette)
    {
        // cuz we have 3 color channels
        Image result = new Image(sourceImage.resolution);

        // [3] because RGB (and we don't dither A)
        int[3][] accumulatedErrors = new int[3][](result.resolution[1] * result.resolution[0]);

        pragma(inline, true)
        void applyError(Color quantizedColor, Color correctedSourceColor, int sourceX, int sourceY)
        {
            foreach(mask; masks_)
            {
                immutable x = sourceX + mask.bias[0];
                immutable y = sourceY + mask.bias[1];

                immutable width = result.resolution[0];
                immutable height = result.resolution[1];

                if (x < 0 || y < 0 || x >= width || y >= height)
                {
                    continue;
                }

                immutable index = y * sourceImage.resolution[0] + x;
                ref errors = accumulatedErrors[index];

                immutable resultErrorR = cast(int) ((correctedSourceColor.r - quantizedColor.r) * mask.errorMultiplier);
                immutable resultErrorG = cast(int) ((correctedSourceColor.g - quantizedColor.g) * mask.errorMultiplier);
                immutable resultErrorB = cast(int) ((correctedSourceColor.b - quantizedColor.b) * mask.errorMultiplier);

                errors[0] += resultErrorR;
                errors[1] += resultErrorG;
                errors[2] += resultErrorB;
            }
        }

        foreach(y; 0..result.resolution[1])
        {
            immutable lineIndex = y * result.resolution[0];
            foreach(x; 0..result.resolution[0])
            {
                immutable sourceColor = sourceImage[x, y];
                immutable int[3] errors = accumulatedErrors[lineIndex + x];

                immutable correctedR = cast(ubyte) (sourceColor.r + errors[0]).clamp(0, 255);
                immutable correctedG = cast(ubyte) (sourceColor.g + errors[1]).clamp(0, 255);
                immutable correctedB = cast(ubyte) (sourceColor.b + errors[2]).clamp(0, 255);

                immutable correctedColor = Color(correctedR, correctedG, correctedB);
                immutable quantizedColor = palette.getClosestOnPalette(correctedColor);
                result[x, y] = quantizedColor;

                applyError(quantizedColor, correctedColor, x, y);
            }
        }

        return result;
    }
} 