module cereslib.math;

import std.traits: isNumeric;

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