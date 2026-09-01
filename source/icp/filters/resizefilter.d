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
    private int[2] resultResolution = [256, 256];

    public @property void resultXResolution(int resolution)
    {
        resolution = resolution.clamp(1, int.max);
        resultResolution[0] = resolution;
    }

    public @property void resultYResolution(int resolution)
    {
        resolution = resolution.clamp(1, int.max);
        resultResolution[1] = resolution;
    }

    public Image filter(const Image image)
    {
        immutable inputResolution = image.resolution;
        Image result = new Image(resultResolution);

        foreach(int y; 0..resultResolution[1])
        foreach(int x; 0..resultResolution[0])
        {
            int remapX = cast(int) remap!double(x, 0, resultResolution[0], 0, inputResolution[0]);
            int remapY = cast(int) remap!double(y, 0, resultResolution[1], 0, inputResolution[1]);

            result[x, y] = image[remapX, remapY];
        }

        return result;
    }
}
