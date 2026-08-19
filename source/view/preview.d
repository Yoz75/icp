module view.preview;
import view;
import icp.image;
import cereslib.math;
import cereslib.todo;
import dlangui;

public final class PreviewWindow : CanvasWidget
{
    private Ref!ColorDrawBufEx imageBuffer_;

    private enum Side
    {
        horizontal,
        vertical
    }

    public @property void imageBuffer(Ref!ColorDrawBufEx buf)
    {
        imageBuffer_ = buf;
    }

    public override void doDraw(DrawBuf buf, Rect rc)
    {
        if(imageBuffer_ is null)
        {
            buf.fill(0x0);
            return;
        }

        /// ARGB but reversed (probably cuz little endian??? Idk but dlangui accepts BGRA)
        struct ColorBGRA
        {
            ubyte b, g, r, a;
        }

        // at some reason DrawBuf doesn't have scan line method so to avoid bilinear interpolation
        // i have to:
        // 1) allocate a new buffer
        // 2) fill this buffer by myself
        // 3) copy this temp buffer to the result buffer
        // Actually, bilinear interpolation IS APPLIED, but, for example, if image buffer is 4x4, 
        // we apply it not for 4x4 grid, but rescale this 4x4 buffer to size of the widget (e,g 500x500) and then apply interpolation 
        // to this 500x500 buffer
        ColorDrawBufEx cacheDrawBuf = new ColorDrawBufEx(buf.width, buf.height);

        immutable height = buf.height;
        immutable width = buf.width;

        foreach(int y; 0..height)
        {
            uint* cacheLinePtr = cacheDrawBuf.scanLine(y);
            // this line says "assume this pointer is a slice of length of the buffer width"
            ColorBGRA[] cacheLine = (cast(ColorBGRA*) cacheLinePtr)[0..cacheDrawBuf.width];

            foreach(int x; 0..width)
            {
                int remapX = cast(int) remap!double(x, 0, width, 0, imageBuffer_.width);
                int remapY = cast(int) remap!double(y, 0, height, 0, imageBuffer_.height);

                uint* linePtr = imageBuffer_.scanLine(remapY);
                ColorBGRA[] line = (cast(ColorBGRA*) linePtr)[0..imageBuffer_.width];

                cacheLine[x] = line[remapX];
            }
        }
        
        immutable cacheDrawBufRect = Rect(0, 0, cacheDrawBuf.width, cacheDrawBuf.height);
        immutable imageRect = Rect(0, 0, imageBuffer_.width, imageBuffer_.height);
        Rect rescaledRect = rc.fit(imageRect);

        buf.fill(0xFFFFFF);
        buf.drawRescaled(rescaledRect, cacheDrawBuf, cacheDrawBufRect);

        super.doDraw(buf, rc);
        cacheDrawBuf.free();
    }
}