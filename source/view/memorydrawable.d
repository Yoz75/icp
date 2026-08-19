module view.memorydrawable;

import dlangui;
import icp.image;
import icp.color;

/// A `Drawable` that uses array of colors as source
public final class MemoryDrawable : ImageDrawable
{
    private ColorDrawBuf drawBuf;
    public this(icp.image.Image source)
    {
        /// ARGB but reversed (probably cuz little endian??? Idk but dlangui accepts BGRA)
        struct ColorBGRA
        {
            ubyte b, g, r, a;
        }

        int[2] resolution = [cast(int) source.resolution[0], cast(int) source.resolution[1]];
        drawBuf = new ColorDrawBuf(resolution[0], resolution[1]);
        
        foreach(y; 0..resolution[1])
        {
            uint* linePtr = drawBuf.scanLine(y);

            // this line says "assume this pointer is a slice of length resolution[0]"
            ColorBGRA[] line = (cast(ColorBGRA*) linePtr)[0..resolution[0]];

            foreach(x; 0..line.length)
            {
                // Source contains RGBA color and we need ARGB so we swap B and A
                // (cuz RGBA's A is ARGB's B)
                immutable colorRGBA = source[x, y];

                /// at some reason dlangui thinks that alfa 0 is opaque and alfa 255 is transparent
                immutable colorARGB = ColorBGRA(colorRGBA.b, colorRGBA.g, colorRGBA.r, 255 - colorRGBA.a);

                line[x] = colorARGB;
            }
        }

        auto refBuf = DrawBufRef(drawBuf);
        super(refBuf);
    }
}
