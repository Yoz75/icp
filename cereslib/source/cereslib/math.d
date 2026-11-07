module cereslib.math;

import std.traits: isNumeric;
import std.math : sqrt, quantize;

/// Remap `value` from diapazone `fromMin`..`fromMax` to `toMin`..`ToMax`
/// Params:
///   value = the value to be remaped
///   fromMin = the old minimum
///   fromMax = the old maximum
///   toMin = the new minimum
///   toMax = the new maximum
/// Returns: the remapped value
public pure T remap(T)(T value, T fromMin, T fromMax, T toMin, T toMax) if(isNumeric!T)
{
    T t = (cast(T) (value - fromMin)) / (cast(T) (fromMax - fromMin));
    return toMin + t * (toMax - toMin);
}

/// Get a dot of `left` and `right` vectors (as static arrays)
/// Params:
///   left = the left vector
///   right = the right vector
/// Returns: 
public T dot(T)(in T[3] left, in T[3] right) pure if(isNumeric!T)
{
    return cast(T) (left[0] * right[0] + left[1] * right[1] + left[2] * right[2]);
}

/// Get euclid distance between 2 vectors
/// Params:
///   left = 
///   right = 
/// Returns: 
public R euclidDistance(T, U, R = real, size_t size = 3)(T[size] left, T[size] right) pure
{
    return sqrt(euclidDistanceSquare(left, right));
}

/// Get squared euclid distance between 2 vectors
/// Params:
///   left = 
///   right = 
/// Returns: 
public R euclidDistanceSquare(T, R = real, size_t size = 3)(T[size] left, T[size] right) pure
{
    R result = 0;

    static foreach(i; 0..size)
    {
        {
            immutable difference = left[i] - right[i];
            result += difference * difference;
        }
    }

    return result;
}

unittest
{
    double[3] a = [2, 1, 0];
    double[3] b = [3, 2, 1];

    // avoid FP errors
    assert(euclidDistance!(double, int)(a, b).quantize(0.0001) == 1.7321);
}