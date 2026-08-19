// some useful shit with rectangles
module view.rectutils;

// Why we actually have std.math if there is nothing useful???????
import std.algorithm.comparison : min;
import dlangui;

/// Rescales the `source` rect so it becomes a subset of destination rect and aspect ration doesn't change
/// i.e result.top >= destination.top; result.bottom <= destionation.bottom;
/// result.left >= destination.left and result.right <= destination.right
/// Params:
///   destionation = 
///   source = 
/// Returns: 
public Rect fit(in Rect destination, in Rect source)
out(result)
{
    assert(result.top >= destination.top);
    assert(result.bottom <= destination.bottom);
    assert(result.left >= destination.left);
    assert(result.right <= destination.right);
}
do
{
    Rect result;
    immutable widthResizeCoefficient = (cast(float) destination.width) / source.width;
    immutable heightResizeCoefficient = (cast(float) destination.height)  / source.height;

    immutable leastCoefficient = min(widthResizeCoefficient, heightResizeCoefficient);
    immutable height = cast(int) (source.height * leastCoefficient);
    immutable width = cast(int) (source.width * leastCoefficient);

    result.top = destination.top + (destination.height - height) / 2;
    result.bottom = result.top + height;

    result.left = destination.left + (destination.width - width) / 2;
    result.right = result.left + width;

    return result;
}