module icp.image;
public import icp.color;

public class Image
{
    public immutable int[2] resolution;
    private Color[][] bitmap;

    public this(int[2] resolution)
    {
        this.resolution = resolution;
        bitmap = new Color[][](resolution[1], resolution[0]);
    }

    public Image dup() inout
    {
        Image result = new Image(resolution);
        
        foreach(y; 0..resolution[1])
        foreach(x; 0..resolution[0])
        {
            result.bitmap[y][x] = bitmap[y][x];
        }

        return result;
    }

    /// Get pixel at [x, y] position
    public ref inout(Color) opIndex(int x, int y) pure inout
    {
        return bitmap[y][x];
    }
    
    void opIndexAssign(Color value, int x, int y)
    {
        bitmap[y][x] = value;
    }
}