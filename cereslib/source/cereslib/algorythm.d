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


/// Find two nearest (the smaller one and the grater one) elements to `position`
/// Params:
///   positions = the array of `T`s
///   position = the "center" element.
/// Returns: array of two indexes of elements in `positions`, first one is the lower neighbor of `position`, the second one is the greatest one
public size_t[2] findNeighborsOf(T)(in T[] positions, in T position) pure if(isNumeric!T)
{
    size_t leastIndex = 0;

    static if(__traits(compiles, {enum value = T.min;}))
    {
        T leastValue = T.min;
    }
    else
    {
        T leastValue = -T.max;
    }

    size_t greatestIndex = positions.length - 1;
    T greatestValue = T.max;

    foreach(i, currentPosition; positions)
    {        
        if(position < currentPosition && currentPosition < greatestValue)
        {
            greatestValue = currentPosition;
            greatestIndex = i;
        }

        if(position > currentPosition && currentPosition > leastValue)
        {
            leastValue = currentPosition;
            leastIndex = i;
        }
    }

    return [leastIndex, greatestIndex];
}

/// Get mean distance between 2 values of array
/// Params:
///   arr = the array
/// Returns: if arr.length <= 1, then 0. Else mean between 2 numbers in `arr`
public real findMeanDistance(T, alias differenceFunction = defaultDiffFunc!T)(T[] arr)
{
    if(arr.length <= 1) return 0;

    real mean = 0;
    foreach(i; 0..arr.length - 1)
    {
        immutable current = arr[i];
        immutable next = arr[i + 1];

        mean += differenceFunction(current, next);
    }

    // because there is length - 1 differences.
    // E.g for 2 numbers, there is only one difference (between first and second number)
    mean /= (arr.length - 1);
    return mean;
}

private T defaultDiffFunc(T)(T left, T right)
{
    return abs(left - right);
}

unittest
{
    float[] arr = [0, 1.34, 2.25, 5, 123];
    assert(findNeighborsOf(arr, 2.25) == [1, 3]);

    float[] arr2 = [0, 1.22, 2.5, 3, 5, 2.5, 8];
    assert(findNeighborsOf(arr2, 2.5) == [1, 3]);
}

unittest
{
    int[$] arr = [0, 5, 10, 15, 10];
    assert(findMeanDistance(arr) == 5);

    float[$] farr = [0, 5, 10, 15, 10];
    assert(findMeanDistance(arr) == 5);

    /*
        because of low precision, this test fails on float array
        writeln still outputs 0.3, so i think the result is something like 0.30000000000042f and this value is not 0.3f, so assert fails
    */
    double[$] arr2 = [0.8, 1, 1.4, 1.6, 2];
    assert(findMeanDistance(arr2) == 0.3);
}