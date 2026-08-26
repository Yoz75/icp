/// Module that glues together ICP images, UI images and loading images from file
module vm.image;

import view.colordrawbufex;
public import cereslib.optional;
import icp.image;
import imageformats;
import dlangui;

public enum ImageLoadErrorCode : ubyte
{
    /// Uninitialized value
    none,
    corruptedImage,
    wrongImageFormat
}

/// Load an image from `path`
/// Params:
///   path = the path to the image
/// Returns: 
public Result!(Image, ImageLoadErrorCode) loadImageFrom(string path)
{
    alias ResultType = Result!(Image, ImageLoadErrorCode);

    IFImage loadedImage;
    try
    {
        loadedImage = read_image(path);
    }
    catch(ImageIOException)
    {
        return ResultType(ImageLoadErrorCode.corruptedImage);
    }
    
    if(loadedImage.c != ColFmt.RGBA && loadedImage.c != ColFmt.RGB)
    {
        return ResultType(ImageLoadErrorCode.wrongImageFormat);
    }

    Image icpImage = new Image([loadedImage.w, loadedImage.h]);

    /*
        OH NO!!!1! CODE DUPLICATION11111!!11!
    */
    if(loadedImage.c == ColFmt.RGBA)
    {
        enum colorSize = 4;
        foreach(int y; 0..icpImage.resolution[1])
        foreach(int x; 0..icpImage.resolution[0])
        {
            immutable index = (y * icpImage.resolution[0] + x) * colorSize;
            immutable icp.color.Color color =
            icp.color.Color(loadedImage.pixels[index],
                loadedImage.pixels[index + 1],
                loadedImage.pixels[index + 2]);

            icpImage[x, y] = color;
        }
    }
    else
    {
        enum colorSize = 3;
        foreach(int y; 0..icpImage.resolution[1])
        foreach(int x; 0..icpImage.resolution[0])
        {
            immutable index = (y * icpImage.resolution[0] + x) * colorSize;
            immutable icp.color.Color color =
            icp.color.Color(loadedImage.pixels[index],
                loadedImage.pixels[index + 1],
                loadedImage.pixels[index + 2]);

            icpImage[x, y] = color;
        }
    }

    return ResultType(icpImage);
}

/// Create a draw buf from image
/// Params:
///   image = the icp image
/// Returns: a new ColorDrawBuf
public Ref!ColorDrawBufEx createDrawBufFromImage(Image image)
{
    /// ARGB but reversed (probably cuz little endian??? Idk but dlangui accepts BGRA)
    struct ColorBGRA
    {
        ubyte b, g, r, a;
    }

    int[2] resolution = [cast(int) image.resolution[0], cast(int) image.resolution[1]];
    ColorDrawBufEx drawBuf = new ColorDrawBufEx(resolution[0], resolution[1]);
    
    foreach(y; 0..resolution[1])
    {
        uint* linePtr = drawBuf.scanLine(y);

        // this line says "assume this pointer is a slice of length resolution[0]"
        ColorBGRA[] line = (cast(ColorBGRA*) linePtr)[0..resolution[0]];

        // we assume line.length < int.max cuz a 2 millin by 2 million texture is a nonsense
        foreach(int x; 0.. cast(int) line.length)
        {
            // Source contains RGBA color and we need ARGB so we swap B and A
            // (cuz RGBA's A is ARGB's B)
            immutable colorRGBA = image[x, y];

            immutable colorARGB = ColorBGRA(colorRGBA.b, colorRGBA.g, colorRGBA.r, 0);

            line[x] = colorARGB;
        }
    }

    return Ref!ColorDrawBufEx(drawBuf);
}   