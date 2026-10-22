module cereslib.algorythm;

import std.math : abs;
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


/// Find two nearest elements to `position`
/// Params:
///   positions = the array of `T`s
///   position = the "center" element.
/// Returns: array of two indexes of elements in `positions`, first one is the smaller neighbor of `position`, the second one is the greatest one
public size_t[2] findNeighborsOf(T)(in T[] positions, in T position) pure if(isNumeric!T)
{
    T nearestDifference = T.max, secondNearestDifference = T.max;
    size_t nearestIndex, secondNearestIndex;

    foreach(i, currentPosition; positions)
    {        
        immutable difference = abs(position - currentPosition);

        if(difference < nearestDifference)
        {
            // cuz currently it's still the second most different
            secondNearestDifference = nearestDifference;
            secondNearestIndex = i;
            
            nearestDifference = difference;
            nearestIndex = i;
        }
        else if(difference < secondNearestDifference)
        {
            secondNearestDifference = difference;
            secondNearestIndex = i;
        }
    }

    return [nearestIndex, secondNearestIndex];
}

unittest
{
    float[] arr = [0, 1.34, 2.25, 5, 123];
    assert(findNeighborsOf(arr, 2.25) == [1, 3]);

    float[] arr2 = [0, 1.22, 2.5, 3, 5, 2.5, 8];
    assert(findNeighborsOf(arr2, 2.5) == [1, 3]);
}