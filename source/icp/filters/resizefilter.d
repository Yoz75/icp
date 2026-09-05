module icp.filters.resizefilter;
import icp.filters.ifilter;
import icp.image;
import cereslib.math;
import std.math;
// CAN U TELL ME Y CLAMP IS NOT IN STD.MATH?????
import std.algorithm.comparison : clamp;
import std.sumtype;

/// Resizes the image
public @filter final class ResizeFilter : IFilter
{
    private SumType!(int[2], float) resultResolution_ = 100f;

    public @property void resultResolution(int[2] resolution)
    {
        resolution[0] = resolution[0].clamp(1, int.max);
        resolution[1] = resolution[1].clamp(1, int.max);

        resultResolution_ = resolution;
    }

    public @property void resultPercentageResolution(float percentage)
    {
        percentage = percentage.clamp(1f, float.max);
        resultResolution_ = percentage;
    }

    public Image filter(const Image image)
    {
        immutable inputResolution = image.resolution;

        int[2] resolution;
        if(resultResolution_.has!(int[2]))
        {
            resolution = resultResolution_.get!(int[2]);
        }
        else
        {
            immutable normalizedPercentage = resultResolution_.get!float / 100f;
            float[2] iCantUseResolutionHereBecauseOfStupidError = inputResolution[] * normalizedPercentage;
            resolution = [cast(int) iCantUseResolutionHereBecauseOfStupidError[0], cast(int) iCantUseResolutionHereBecauseOfStupidError[1]];

            resolution[0] = resolution[0].clamp(1, int.max);
            resolution[1] = resolution[1].clamp(1, int.max);
        }

        Image result = new Image(resolution);

        foreach(int y; 0..resolution[1])
        foreach(int x; 0..resolution[0])
        {
            int remapX = cast(int) remap!double(x, 0, resolution[0], 0, inputResolution[0]);
            int remapY = cast(int) remap!double(y, 0, resolution[1], 0, inputResolution[1]);

            result[x, y] = image[remapX, remapY];
        }

        return result;
    }
}
