/// Module that glues together ICP images, UI images and loading images from file
module vm.image;

import view.colordrawbufex;
public import cereslib.optional;
import icp.image;
import std.array : split;
import arsd.image;
import dlangui;

/// What went wrong when loading an image?
public enum ImageLoadErrorCode : ubyte
{
    /// Uninitialized value
    none,
    corruptedImage,
    wrongImageFormat
}

/// What went wrong when saving an image?
public enum ImageSaveErrorCode : ubyte
{
    /// Uninitialized value
    none,
    unknownFormat
}

/// Load an image from `path`
/// Params:
///   path = the path to the image
/// Returns: 
public Result!(Image, ImageLoadErrorCode) loadImageFrom(string path)
{
    alias ResultType = Result!(Image, ImageLoadErrorCode);

    MemoryImage loadedImage;
    try
    {
        loadedImage = loadImageFromFile(path);
    }
    catch(Exception ex)
    {
        import applogger; globalAppLogger.log(ex.msg, LogType.debug_);
        return ResultType(ImageLoadErrorCode.corruptedImage);
    }

    Image icpImage = new Image([loadedImage.width, loadedImage.height]);

    foreach(y; 0..loadedImage.height)
    foreach(x; 0..loadedImage.width)
    {
        ref color = icpImage[x, y];
        color.value = loadedImage.getPixel(x, y).asUint;
    }

    return ResultType(icpImage);
}

public Optional!ImageSaveErrorCode saveTrueColorImageTo(string path, Image image)
{
    alias ResultType = Optional!(ImageSaveErrorCode);
    immutable extension = path.split(".")[$-1];

    TrueColorImage arsdImage = new TrueColorImage(image.resolution[0], image.resolution[1]);

    foreach(y; 0..arsdImage.height)
    foreach(x; 0..arsdImage.width)
    {
        auto color = image[x, y];
        arsd.color.Color arsdColor = arsd.color.Color(color.r, color.g, color.b, 255);

        arsdImage.setPixel(x, y, arsdColor);
    }

    switch(extension)
    {
        case "png":  writePng(path, arsdImage);                break;
        case "jpg":                                 goto case "jpeg";
        case "jpeg": writeJpeg(path, arsdImage);               break;
        default: return ResultType(ImageSaveErrorCode.unknownFormat);
    }

    return none!ImageSaveErrorCode;
}

public Image createImageFromDrawBuf(Ref!ColorDrawBufEx buffer)
{
    /// ARGB but reversed (probably cuz little endian??? Idk but dlangui accepts BGRA)
    struct ColorBGRA
    {
        ubyte b, g, r, a;
    }

    Image icpImage = new Image([buffer.width, buffer.height]);

    foreach(y; 0..buffer.height)
    {
        uint* linePtr = buffer.scanLine(y);

        ColorBGRA[] line = (cast(ColorBGRA*) linePtr)[0..icpImage.resolution[0]];

        foreach(x; 0..buffer.width)
        {
            immutable bgraColor = line[x];
            icpImage[x, y] = icp.color.Color(bgraColor.r, bgraColor.g, bgraColor.b);
        }
    }

    return icpImage;
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