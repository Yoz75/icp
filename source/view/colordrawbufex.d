module view.colordrawbufex;
import dlangui;

// this thing is buggy too so nevermind
/// `ColorDrawBuf` that fixes memory leak (YES, BASIC COLOR DRAW BUF LITERALLY LEEKS DOZENS OF BYTES).
/// Should be used with `Ref(T)`
public final class ColorDrawBufEx : ColorDrawBuf
{
    this(int width, int height)
    {
        super(width, height);
    }

    public void free()
    {
        //_buf.clear();
    }
}