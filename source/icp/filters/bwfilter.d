module icp.filters.bwfilter;

import icp.filters.ifilter;
import icp.image;
import icp.color;
import std.algorithm : clamp;

/// Black and White Filter
public @filter final class BW_Filter : IFilter
{
    private float effectStrength_ = 1;

    public @property void effectStrength(float value) 
    {
        effectStrength_ = value.clamp(0, 1);
    }

    public Image filter(const Image image)
    {
        enum rMultiplier = 0.2126;
        enum gMultiplier = 0.7152;
        enum bMultiplier = 0.0722;

        Image result = image.dup;

        foreach(y; 0..result.resolution[1])
        foreach(x; 0..result.resolution[0])
        {
            ref Color color = result[x, y];
            immutable ubyte brightness = cast (ubyte)
            ( color.r * rMultiplier +
              color.g * gMultiplier + 
              color.b * bMultiplier);

            Color brightnessColor = Color(brightness, brightness, brightness, color.a);

            color = color.lerp(brightnessColor, effectStrength_);
        }

        return result;
    }
}