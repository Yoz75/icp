module cereslib.conv;

import std.traits : isNumeric;
import std.algorithm : clamp;

/// Conevrt one numeric static array to another
/// Params:
///   arr = the array of type T
/// Returns: the array of type U
public U[size] toStaticArray(T, U, size_t size = 3)(T[size] arr) pure if(isNumeric!T && isNumeric!U)
{
    static if(__traits(compiles, {U v = U.min;}))
    {
        enum minU = U.min;
    }
    else
    {
        enum minU = -U.max;
    }

    static if(__traits(compiles, {T v = T.min;}))
    {
        enum minT = T.min;
    }
    else
    {
        enum minT = -T.max;        
    }

    static if(minT > minU)
    {
        enum min = minT;
    }
    else
    {
        enum min = minU;
    }

    static if(T.max < U.max)
    {
        enum max = T.max;
    }
    else
    {
        enum max = U.max;
    }
    
    U[size] result;
    static foreach(i; 0..size)
    {
        result[i] = cast(U) arr[i].clamp(min, max);
    }

    return result;
}

unittest
{
    ubyte[4] arr = [123, 255, 132, 32];
    assert(arr.toStaticArray!(ubyte, float, 4) == [123f, 255f, 132f, 32f]);
}