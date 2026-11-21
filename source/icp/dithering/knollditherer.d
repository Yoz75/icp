module icp.dithering.knollditherer;

import icp.dithering.pditherer;
import icp.exceptions;
import icp.dithering.bayer;
import cereslib.math;
import cereslib.properties;
import cereslib.algorythm;
import cereslib.conv;
import std.algorithm : sort, map, sum;
import std.range;
import std.array : array;
import std.parallelism : parallel;

/// A ditherer that uses Knoll's algorythm
public final class KnollDitherer(TPalette) : IDitherer!TPalette if(is(TPalette : IPalette))
{
    /*
        I copypasted some code from bayer ditherer (and random btw) but i hope it's ok
        cuz rewriting all ditherers to support attaching one to another is annoying
    */

public:

    private @min!uint(1) @max!uint(16) uint samplesCount_ = 8;

    private @max!uint(14u) uint matrixLevel_ = 1;
    private @min!float(0.05) @max!float(1) float strength_ = 1f;

    mixin MakeGetter!samplesCount_;
    mixin MakeSetter!samplesCount_;

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
    protected override Image dither(const Image sourceImage, TPalette palette)
    {
        Color[] colors = palette.get();
        colors.sort!((a, b) => a.getBrightness < b.getBrightness)();
        
        Bayer bayer = Bayer(matrixLevel_);
        float[3][] positions = colors.map!(c => cast(float[3])[c.r, c.g, c.b]).array;
        Image result = new Image(sourceImage.resolution);

        /// i guess it would be too expensive to allocate it each pixel!
        foreach(y; iota(0, result.resolution[1]).parallel())
        foreach(x; iota(0, result.resolution[0]).parallel())
        {
            auto probabilities =  new float[colors.length];
            probabilities[] = 0;

            immutable sourceColor = sourceImage[x, y];
            float[3] goalPosition = sourceColor.rgb.toStaticArray!(ubyte, float);

            foreach (i; 0..samplesCount_)
            {
                auto currentPositionIndex = positions.findIndexOfNearest!(float[3], (left, right) => euclidDistanceSquare!(float, float)(left, right))(goalPosition);
                probabilities[currentPositionIndex]++;

                /*
                    start of the arrays hell
                */
                float[3] sourceRGB = sourceColor.rgb.toStaticArray!(ubyte, float);
                float[3] currentRGB = colors[currentPositionIndex].rgb.toStaticArray!(ubyte, float);

                float[3] goalDelta = sourceRGB[] - currentRGB[];
                
                goalPosition[] += goalDelta[];
                /*
                    end of the arrays hell
                */
            }
			
            probabilities[] /= probabilities.sum;

            immutable bayerThreshold = bayer.evaluateNormalized(x % bayer.size, y % bayer.size);
            immutable totalThreshold = bayerThreshold;

            float cumulativeSum = 0;
            foreach(i; 0..colors.length)
            {
                immutable probability = probabilities[i];
                cumulativeSum += probability;

                if(cumulativeSum > totalThreshold * strength_)
                {
                    result[x, y] = colors[i];
                    break;
                }
            }
        }

        return result;
    }
}