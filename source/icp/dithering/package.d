/// Various dithering algorythms and some garbage
module icp.dithering;

public import icp.dithering.iditherer;
public import icp.dithering.noditherer;
public import icp.dithering.ditherer;

/// `Ditherer` that uses Two Row Sierra as default mask (you still can change it but idk why you need to)
/*public final class TwoRowSierra : Ditherer
{
    public this()
    {
        masks = [

        ];
    }
}*/

/// Uses Floyd-Steinberg dithering algorythm
public final class FloydSteinbergDitherer : Ditherer
{
    public this()
    {
        masks = [
            DitherMask(7f / 16f, [1, 0]),
            DitherMask(3f / 16f, [-1, 1]),
            DitherMask(5f / 16f, [0, 1]),
            DitherMask(1f / 16f, [1, 1])
        ];
    }
}

/// Accumulates error on the right pixel. Super fast
public final class RightPropagationDitherer : Ditherer
{
    public this()
    {
        masks = [
            DitherMask(1, [1, 0]),
        ];
    }
}