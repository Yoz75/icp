module cereslib.algorythm;

import std.traits : isNumeric;

/// Perform `action` for each subarray in `colors`
/// Params:
///   colors = the array
///   subArraysCount = the count of subarrays
///   params = additional parameters of the function
public void forEachSubArray(T, alias action, TParams...)(T[] array, size_t subArraysCount, TParams params)
{
    for (size_t subarrayIndex = 0; subarrayIndex < subArraysCount; ++subarrayIndex)
    {
        size_t begin = array.length * subarrayIndex / subArraysCount;
        size_t end = array.length * (subarrayIndex + 1) / subArraysCount;
        action(array[begin .. end], params);
    }
}

/// Get index of most similar to `value` element of `sortedArray`
/// Params:
///   sortedArray = the array of all values
///   value = the target value
/// Returns: index of most similar value or size_t.max
public size_t findIndexOfNearest(T)(in T[] positions, in T targetPosition) pure if(isNumeric!T)
{
    import std.math : abs;
    if (positions.length == 0)
        return size_t.max;

    size_t nearestIndex = 0;
    float nearestDistance = abs(positions[0] - targetPosition);
    foreach (index, position; positions)
    {
        immutable distance = abs(position - targetPosition);
        if (distance < nearestDistance)
        {
            nearestDistance = distance;
            nearestIndex = index;
        }
    }
    
    return nearestIndex;
}