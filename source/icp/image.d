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


/// Find all unique colors in the image and return array of the colors
/// Params:
///   image = the image 
/// Returns: array  of colors
private Color[] findColors(in Image image) pure
{
    struct Dummy{};
    Dummy[Color] registeredColors;

    foreach(y; 0..image.resolution[1])
    foreach(x; 0..image.resolution[0])
    {
        Color currentColor = image[x, y];
        Dummy* colorAppearances = currentColor in registeredColors;

        if(colorAppearances is null)
        {
            registeredColors[currentColor] = Dummy();
        }
    }

    return registeredColors.keys;
}


/// Find all unique colors and their appearances in the image and return array of the colors and array of counts of appearances of everyColor
/// Params:
///   image = the image 
///   appearances = array, containing count of appearances of each color. For example, `appearances[0]` equals appearances count of the first color in the result array
/// Returns: array  of colors
public Color[] findColors(in Image image, out uint[] appearances) pure
{
    uint[Color] registeredColors;

    foreach(y; 0..image.resolution[1])
    foreach(x; 0..image.resolution[0])
    {
        Color currentColor = image[x, y];
        uint* colorAppearances = currentColor in registeredColors;
        if(colorAppearances is null)
        {
            registeredColors[currentColor] = 1;
        }
        else
        {
            (*colorAppearances)++;
        }
    }

    appearances = registeredColors.values;
    return registeredColors.keys;
}