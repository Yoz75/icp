module icp.color;
import std.traits : isNumeric;


public struct Color
{
    union
    {
        struct 
        {
            ubyte r, g, b, a = 255;
        }

        ubyte[4] rgba;
        uint value;
    }
}

unittest
{
    Color color;
    color.rgba[0] = 128;
    color.rgba[1] = 129;
    color.rgba[2] = 130;
    color.rgba[3] = 255;
    
    assert(color.r == 128);
    assert(color.g == 129);
    assert(color.b == 130);
    assert(color.a == 255);
}

/// copypaste from sednalib from repowdered
public Color lerp(T)(in Color from, in Color to, in T lerpFactor) pure if (isNumeric!T)
{
    Color result;

    result.r = cast(ubyte)(from.r + (to.r - from.r) * lerpFactor);
    result.g = cast(ubyte)(from.g + (to.g - from.g) * lerpFactor);
    result.b = cast(ubyte)(from.b + (to.b - from.b) * lerpFactor);
    result.a = cast(ubyte)(from.a + (to.a - from.a) * lerpFactor);

    return result;
}
