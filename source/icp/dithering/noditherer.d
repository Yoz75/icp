module icp.dithering.noditherer;
import icp.dithering.iditherer;
import icp.image;

/// Ditherer that doesn't dither the image and just applies quantized colors
public final class NoDitherer : IDitherer
{
    /// Dither an image.
    /// Params:
    /// sourceImage = the original not quantized image
    /// source2DestinationColorMap = associative array, that maps colors from the source image to quanitzed colors
    /// Returns: quantized and dithered image. All colors 
    public Image dither(const Image sourceImage, Color[Color] source2DestinationColorMap)
    {
        Image result = new Image(sourceImage.resolution);

        foreach(y; 0..sourceImage.resolution[1])
        foreach(x; 0..sourceImage.resolution[0])
        {
            Color color = sourceImage[x, y];
            result[x, y] = source2DestinationColorMap[color];
        }

        return result;
    }
}