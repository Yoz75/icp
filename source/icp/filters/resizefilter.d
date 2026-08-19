module icp.filters.resizefilter;
import icp.filters.ifilter;
import icp.image;
import std.math;
// CAN U TELL ME Y CLAMP IS NOT IN STD.MATH?????
import std.algorithm.comparison : clamp;
import cereslib.math;

/// Resizes the image
public @filter final class ResizeFilter : IFilter
{
    private size_t[2] resultResolution = [16, 16];

    public @property void resultXResolution(size_t resolution)
    {
        resolution = resolution.clamp(1, size_t.max);
        resultResolution[0] = resolution;
    }

    public @property void resultYResolution(size_t resolution)
    {
        resolution = resolution.clamp(1, size_t.max);
        resultResolution[1] = resolution;
    }

    public Image filter(const Image image)
    {
        immutable inputResolution = image.resolution;
        Image result = new Image(resultResolution);

        foreach(y; 0..resultResolution[1])
        foreach(x; 0..resultResolution[0])
        {
            size_t remapX = cast(size_t) remap!double(x, 0, resultResolution[0], 0, inputResolution[0]);
            size_t remapY = cast(size_t) remap!double(y, 0, resultResolution[1], 0, inputResolution[1]);

            result[x, y] = image[remapX, remapY];
        }

        return result;
    }
}
