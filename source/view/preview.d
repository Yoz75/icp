module view.preview;
import view;
import settings;
import icp.image;
import cereslib.math;
import cereslib.todo;
import dlangui;

public final class PreviewWindow : CanvasWidget
{
    private Ref!ColorDrawBufEx imageBuffer_;
    private Ref!ColorDrawBufEx cacheDrawBuf;
    private bool shoouldUpdate;

    private enum Side
    {
        horizontal,
        vertical
    }

    public @property void imageBuffer(Ref!ColorDrawBufEx buf)
    {
        imageBuffer_ = buf;
        shoouldUpdate = true;
    }

    public override void doDraw(DrawBuf buf, Rect rc)
    {
        if(imageBuffer_ is null)
        {
            buf.fill(0x0);
            return;
        }

        if(!shoouldUpdate)
        {
            drawCacheBuffer(buf, rc);
            return;
        }

        immutable int imageWidth = imageBuffer_.width;
        immutable int imageHeight = imageBuffer_.height;

        immutable int bufferWidth = buf.width;
        immutable int bufferHeight = buf.height;

        if(imageWidth <= 0 || imageHeight <= 0 || bufferWidth <= 0 || bufferHeight <= 0)
        {
            return;
        }

        immutable threshold = Settings.instance.pointInterpolationThreshold;
        immutable proportion = cast(float) (imageBuffer_.height * imageBuffer_.width) / cast(float) (buf.height * buf.width);
        immutable usePointInterpolation = proportion < threshold;

        immutable cacheWidth = usePointInterpolation ? bufferWidth : imageWidth;
        immutable cacheHeight = usePointInterpolation ? bufferHeight : imageHeight;

        cacheDrawBuf = new ColorDrawBufEx(cacheWidth, cacheHeight);

        foreach (int destinationY; 0..cacheHeight)
        {
            immutable int sourceY = destinationY * imageHeight / cacheHeight;

            uint* sourceLine = imageBuffer_.scanLine(sourceY);
            uint* destinationLine = cacheDrawBuf.scanLine(destinationY);

            foreach (int destinationX; 0..cacheWidth)
            {
                immutable int sourceX =
                    destinationX * imageWidth / cacheWidth;

                destinationLine[destinationX] = sourceLine[sourceX];
            }
        }

        drawCacheBuffer(buf, rc);

        super.doDraw(buf, rc);
        cacheDrawBuf.free();
        shoouldUpdate = false;
    }

    /// Draw the cache buffer into another buffer
    /// Params:
    ///   buf = the buffer in witch we draw the cache buffer
    ///   rc =  buf's rect
    private void drawCacheBuffer(DrawBuf buf, Rect rc)
    {
        immutable cacheDrawBufRect = Rect(0, 0, cacheDrawBuf.width, cacheDrawBuf.height);
        immutable imageRect = Rect(0, 0, imageBuffer_.width, imageBuffer_.height);
        Rect rescaledRect = rc.fit(imageRect);

        buf.fill(0x0);
        buf.drawRescaled(rescaledRect, cacheDrawBuf, cacheDrawBufRect);
    }
}