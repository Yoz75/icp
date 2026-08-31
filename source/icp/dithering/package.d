/// Various dithering algorythms and some garbage
module icp.dithering;

public import icp.dithering.iditherer;
public import icp.dithering.noditherer;
public import icp.dithering.ditherer;
public import icp.dithering.randomditherer;
import icp.palettes;

// Most of the algorythms I took from https://habr.com/ru/articles/326936/

/// Uses Floyd-Steinberg dithering algorythm
public final class FloydSteinbergDitherer(TPalette) : Ditherer!TPalette if(is(TPalette : IPalette))
{
    public this()
    {
        masks = [
            DitherMask(7f / 16, [1, 0]),
            DitherMask(3f / 16, [-1, 1]),
            DitherMask(5f / 16, [0, 1]),
            DitherMask(1f / 16, [1, 1])
        ];
    }
}

/// Accumulates error on the right pixel. Super fast
public final class RightPropagationDitherer(TPalette) : Ditherer!TPalette if(is(TPalette : IPalette))
{
    public this()
    {
        masks = [
            DitherMask(1f, [1, 0]),
        ];
    }
}

/// Full Sierra's ditherer
public final class SierraThreeDitherer(TPalette) : Ditherer!TPalette if(is(TPalette : IPalette))
{
    public this()
    {
        masks = [
            DitherMask(5f/32, [1, 0]),
            DitherMask(3f/32, [2, 0]),

            DitherMask(2f/32, [-2, 1]),
            DitherMask(4f/32, [-1, 1]),
            DitherMask(5f/32, [0, 1]),
            DitherMask(4f/32, [1, 1]),
            DitherMask(2f/32, [2, 1]),

            DitherMask(2f/32, [-1, 2]),
            DitherMask(3f/32, [0, 2]),
            DitherMask(2f/32, [1, 2]),
        ];
    }
}

/// Medium Sierra's ditherer
public final class SierraTwoRowDitherer(TPalette) : Ditherer!TPalette if(is(TPalette : IPalette))
{
    public this()
    {
        masks = [
            DitherMask(4f/16, [1, 0]),
            DitherMask(3f/16, [2, 0]),

            DitherMask(1f/16, [-2, 1]),
            DitherMask(2f/16, [-1, 1]),
            DitherMask(3f/16, [0, 1]),
            DitherMask(2f/16, [1, 1]),
            DitherMask(1f/16, [2, 1]),
        ];
    }
}

/// Tiny Sierra's ditherer
public final class SierraLightDitherer(TPalette) : Ditherer!TPalette if(is(TPalette : IPalette))
{
    public this()
    {
        masks = [
            DitherMask(2f/4, [1, 0]),

            DitherMask(1f/4, [0, 1]),
            DitherMask(1f/4, [-1, 1]),
        ];
    }
}