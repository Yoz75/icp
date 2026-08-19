import dlangui;
import vm;
import view;
import vm.logging;
import std.sumtype : has, get;
import std.file : getcwd;
import std.path : chainPath;
import std.array : array;

mixin APP_ENTRY_POINT;

private Logger appLogger;

/*туду на завтра:
1) доделать StateWidget так, чтобы обойтись без fromString (хранить список состояний просто)
2) попытаться оптимизировать дизеринг, посмотреть реализацию пэинтнета https://github.com/paintdotnet/PaintDotNet.Quantization/tree/main/PaintDotNet/Imaging/Quantization 
*/

extern(C) int UIAppMain(string[] args)
{
    registerDefaultPresets();

    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    Window window = Platform.instance.createWindow("Wow!", null, 0, 800, 600);
    window.windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;

    auto frame = new MainFrame();
    window.mainWidget = frame;

    appLogger = new Logger();
    appLogger.addLoggee(new StatusLineLoggee(frame.statusLine));
    appLogger.addLoggee(new FileLoggee(chainPath(getcwd(), "Logs").array));

    window.show();
    return Platform.instance.enterMessageLoop();
}

private final class MainFrame : AppFrame
{
    /// path to the last open file
    private string lastFilePath;

    protected override void initialize()
    {
        _appName = "wow!";
        super.initialize();
    }

    protected override Widget createBody()
    {
        auto body = parseML(import("mainWindow.dml"));

        string fileName;
        ICP_VM icp = new ICP_VM();

        auto openFileButton = body.childById!Button("openFileButton");

        openFileButton.click = (widget)
        {
            import std : to;
            import dlangui.dialogs.filedlg : FileDialog, FileFilterEntry;
            import dlangui.dialogs.dialog : Dialog;

            auto dialog = new FileDialog(UIString.fromRaw("Open image..."d), window);
            dialog.addFilter(FileFilterEntry(UIString.fromRaw("Images (png|jpg|bmp|tga)"d),
             "*.png;*.jpg;*.jpeg;*.bmp;*.tga"));

            if(lastFilePath.length > 0)
            {
               import std.path : dirName;
               dialog.path = lastFilePath.dirName;
            }
            
            dialog.dialogResult = (Dialog unused, const Action action)
            {
                fileName = action.stringParam;
                lastFilePath = action.stringParam;
            };

            dialog.show();
            return true;
        };

        PreviewWindow preview = cast(PreviewWindow) new PreviewWindow();
        preview.minWidth = makePercentSize(100);
        preview.minHeight = makePercentSize(100);

        preview.backgroundColor = "#FF00FF";
        body.childById("previewSide").addChild(preview);

        auto runButton = body.childById!Button("runButton");
        runButton.click = (widget)
        {
            if(fileName.length <= 0) return true;
            import icp.image : Image;

            try
            {
                auto buffer = icp.process(fileName);
                
                if(buffer.has!(ICP_VM.ProcessError))
                {
                    immutable errorCode = buffer.get!(ICP_VM.ProcessError);
                    string error;

                    final switch(errorCode)
                    {
                        case ICP_VM.ProcessError.none:
                            error = "Got process error while executing ICP, but its code is none (invalid).";
                            break;
                        case ICP_VM.ProcessError.wrongImageFormat:
                            error = "Unknown image format.";
                            break;
                        case ICP_VM.ProcessError.corruptedImage:
                            error = "Image is corrupted or contains unsupported features and can not be loaded." ~
                                    "Try to open and resave it in some editor :(";
                            break;
                    }

                    appLogger.log(error, LogType.error);
                    return true;
                }

                preview.imageBuffer = buffer.get!ColorDrawBuf;
            }
            catch(Exception ex)
            {
                appLogger.log("Unhandled exception while running ICP :(. Message: " ~ ex.message.to!string, LogType.error);
            }

            import core.memory;
            immutable gcMemoryUsage = GC.stats.usedSize / (1024f * 1024f);
            appLogger.log("Used memory after processing: " ~ gcMemoryUsage.to!string ~ "MiB", LogType.debug_);
            appLogger.log("Processed an image. No errors occured.");
            return true;
        };

        auto presetView = body.childById!VerticalLayout("presetView");
        auto presetsComboBox = body.childById!ComboBox("presetsComboBox");

        icp.selectPreset(globalRegisteredPresets[0], presetView);

        // bruh dlangui lets me assign a value to items but doesn't let me append >:(
        dstring[] presetNames = new dstring[globalRegisteredPresets.length];
        foreach(i, preset; globalRegisteredPresets)
        {
            presetNames [i] = preset.name;
        }

        presetsComboBox.items = presetNames;

        presetsComboBox.itemClick = (widget, int index)
        {        
            immutable name = presetsComboBox.items[index].value;

            //oh god linear search!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            foreach(preset; globalRegisteredPresets)
            {
                if(preset.name == name)
                {
                    icp.selectPreset(preset, presetView);
                    break;
                }
            }

            return true;
        };

        return body;
    }
}