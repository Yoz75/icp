module icp.color;
import std.math : sqrt, round, abs;
import std.traits : isNumeric;


public struct Color
{
    union
    {
        struct 
        {
            ubyte r, g, b;
        }

        ubyte[3] rgb;
        uint value;
    }
}

unittest
{
    Color color;
    color.rgb[0] = 0x11;
    color.rgb[1] = 0x10;
    color.rgb[2] = 0xFA;
    
    assert(color.r == 0x11);
    assert(color.g == 0x10);
    assert(color.b == 0xFA);
}

/// copypaste from sednalib from repowdered
public Color lerp(T)(in Color from, in Color to, in T lerpFactor) pure if (isNumeric!T)
{
    Color result;

    result.r = cast(ubyte)(from.r + (to.r - from.r) * lerpFactor);
    result.g = cast(ubyte)(from.g + (to.g - from.g) * lerpFactor);
    result.b = cast(ubyte)(from.b + (to.b - from.b) * lerpFactor);

    return result;
}

/// Get distance between two colors
/// Params:
///   first = first color
///   second = second color
/// Returns: 
public int distance(Color first, Color second) pure
{
    return cast(int) sqrt(cast(float) distanceSquare(first, second)).round();
}

/// Get squared distance between two colors (can be used to compare distaces)
/// Params:
///   first = first color
///   second = second color
/// Returns: 
public int distanceSquare(Color first, Color second) pure
{
    immutable rDifference = second.r = first.r;
    immutable gDifference = second.g - first.g;
    immutable bDifference = second.b - first.b;

    return (rDifference * rDifference) + (gDifference * gDifference) + (bDifference * bDifference);
}

/// Get Manhattan distance between 2 colors
/// Params:
///   first = first color
///   second = second color
/// Returns: manhattan distance
public int manhattanDistance(Color first, Color second) pure
{
    immutable rDifference = cast(ubyte) (first.r - second.r).abs;
    immutable gDifference = cast(ubyte) (first.g - second.g).abs;
    immutable bDifference = cast(ubyte) (first.b - second.b).abs;

    return rDifference + gDifference + bDifference;
}

/// Get index in `slice` of the most similar `slice`'s element to the `color`
/// Params:
///   slice = the slice of colors
///   color = the target color
/// Returns: index in `slice` of the most similar `slice`'s element to the `color`
public size_t getIndexOfMostSimilar(alias distanceFun = distanceSquare)(Color[] slice, Color color) pure
{
    int minDistance = int.max;
    size_t mostSimilarIndex;

    foreach(i, found; slice)
    {
        immutable distance = distanceFun(color, found);

        if(distance < minDistance)
        {
            minDistance = distance;
            mostSimilarIndex = i;
        }
    }

    return mostSimilarIndex;
}