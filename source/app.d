import vm;
import view;
import vm.logging;
import applogger;
import cereslib.versions;
import std.sumtype : has, get;
import std.file : getcwd;
import std.path : chainPath;
import std.array : array;
import std : to;
import std.path : dirName;
import dlangui;
import dlangui.dialogs.filedlg : FileDialog, FileFilterEntry, FileDialogFlag;
import dlangui.dialogs.dialog : Dialog;

mixin APP_ENTRY_POINT;

extern(C) int UIAppMain(string[] args)
{
    programVersion = Version.fromString(import("version.txt"));

    import std.stdio;
    stderr = File("./err.txt", "w");
    stdout = File("./out.txt", "w");

    registerDefaultPresets();
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    Platform.instance.uiTheme = "theme_neo_dark";

    immutable width = 800;
    immutable height = 600;
    Window window = Platform.instance.createWindow("ICP " ~ programVersion.toDstring(), null, WindowFlag.Resizable, width, height);
    window.windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;

    auto frame = new MainFrame();
    window.mainWidget = frame;

    globalAppLogger = new Logger();
    globalAppLogger.addLoggee(new StatusLineLoggee(frame.statusLine));
    globalAppLogger.addLoggee(new ErrorMessageBoxLogging(window));
    globalAppLogger.addLoggee(new FileLoggee(chainPath(getcwd(), "Logs").array));

    window.show();
    return Platform.instance.enterMessageLoop();
}

// I don't like the idea of actions but i have to use them🫩
enum ActionIds : int
{
    openFileAction = 100_000,
    saveFileAction,
    runAction,
    settingsAction
}

private final class MainFrame : AppFrame
{
    /// path to the last open file
    private string currentFilePath;
    private Ref!ColorDrawBufEx currentImage;
    private PreviewWindow preview;
    private ICP_VM icp = new ICP_VM();

    protected override void initialize()
    {
        _appName = "wow!";
        super.initialize();
    }

    protected override StatusLine createStatusLine()
    {
        return new LogLine(16);
    }

    protected override MainMenu createMainMenu()
    {
        return MainMenuMaker.makeMainMenu();
    }

    protected override ToolBarHost createToolbars() => null;

    protected override bool handleAction(const Action action)
    {
        if(!action) return false;
        
        with(ActionIds)
        final switch(action.id)
        {
            case openFileAction: openFile();           break;
            case saveFileAction: saveFile();           break;
            case runAction:      run();                break;
            case settingsAction: openSettingsWindow(); break;
        }
        
        return true;
    }

    protected override Widget createBody()
    {
        auto body = parseML(import("mainWindow.dml"));

        preview = cast(PreviewWindow) new PreviewWindow();
        preview.minWidth = makePercentSize(100);
        preview.minHeight = makePercentSize(100);

        preview.backgroundColor = "#FF00FF";
        body.childById("previewSide").addChild(preview);

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

        body.childById!Button("runButton").click = (Widget unused)
        {
            run();
            return true;
        };

        return body;
    }

    private void openFile()
    {
        auto dialog = new FileDialog(UIString.fromRaw("Open image..."d), window);
        dialog.styleId = "ICP_DEFAULT_LAYOUT";
        dialog.addFilter(FileFilterEntry(UIString.fromRaw("Images (png|jpg|bmp|tga)"d),
         "*.png;*.jpg;*.jpeg;*.bmp;*.tga"));

        if(currentFilePath.length > 0)
        {
           dialog.path = currentFilePath.dirName;
        }
        
        dialog.dialogResult = (Dialog unused, const Action action)
        {
            currentFilePath = action.stringParam;
        };

        dialog.show();
    }

    private void saveFile()
    {
        if(currentImage is null) return;
        auto dialog = new FileDialog(UIString.fromRaw("Save image..."d), 
        window, fileDialogFlags: FileDialogFlag.Save | FileDialogFlag.EnableCreateDirectory);
        dialog.styleId = "ICP_DEFAULT_LAYOUT";
        dialog.filename = "save.png";

        dialog.dialogResult = (Dialog unused, const Action action)
        {
            try
            {
                icp.save(currentImage, action.stringParam);
            }
            catch(Exception ex)
            {
                globalAppLogger.log("Could not save image: " ~ ex.message.to!string, LogType.error);
            }
        };

        dialog.show();        
    }

    private void run()
    {
        import icp.image : Image;
        if(currentFilePath.length <= 0) 
        {
            globalAppLogger.log("Open an image before processing.", LogType.warning);
            return;
        }

        try
        {
            auto buffer = icp.process(currentFilePath);
            
            if(!buffer.hasValue)
            {
                immutable errorCode = buffer.error;
                string error;

                final switch(errorCode)
                {
                    case ICP_VM.ProcessError.none:
                        error = "Got process error while executing ICP, but its code is none (invalid).";
                            break;
                        case ICP_VM.ProcessError.wrongImageFormat:
                            error = "Unknown image format. Try to resave the image";
                            break;
                        case ICP_VM.ProcessError.corruptedImage:
                            error = "Image is corrupted or contains unsupported features and can not be loaded." ~
                                    "Try to open and resave it in some editor :(";
                            break;
                    }

                    globalAppLogger.log(error, LogType.error);
                    return;
                }

                currentImage = buffer.value;
                preview.imageBuffer = currentImage;
        }
        catch(Exception ex)
        {
            globalAppLogger.log("An error occured: " ~ ex.message.to!string, LogType.error);
        }

        // During processing, ICP allocates a lot of stuff
        globalAppLogger.logGCMemory();
        globalAppLogger.log("Calling GC.collect() and GC.minimize()...");
        import core.memory; GC.collect(); GC.minimize();
        globalAppLogger.logGCMemory();
    } 

    private void openSettingsWindow()
    {
        import windows.settings;

        auto window = new SettingsWindow("Settings"d, window);
        window.show;
    }
}

private final abstract class MainMenuMaker
{
    private enum FolderIds
    {
        fileFolder = 0,
        editFolder
    }
static:
    const Action openFileAction
     = new Action(ActionIds.openFileAction, "Open image..."d).addAccelerator(KeyCode.F6)
                                                             .addAccelerator(KeyCode.KEY_O, KeyFlag.Control);
    const Action saveFileAction 
     = new Action(ActionIds.saveFileAction, "Save image..."d).addAccelerator(KeyCode.F7)
                                                             .addAccelerator(KeyCode.KEY_S, KeyFlag.Control);
    const Action runAction
     = new Action(ActionIds.runAction, "Run"d).addAccelerator(KeyCode.F5)
                                              .addAccelerator(KeyCode.KEY_F, KeyFlag.Control);
    const Action settingsAction
     = new Action(ActionIds.settingsAction, "Settings..."d).addAccelerator(KeyCode.F13)
                                                           .addAccelerator(KeyCode.KEY_S, KeyFlag.Alt);                      

    // I moved all the menu-shit here cuz other parts of MainFrame shouldn't know about ActionIds for example
    public MainMenu makeMainMenu()
    {
        auto menuFolders = new MenuItem();

        menuFolders.add(createFileFolder());
        menuFolders.add(createEditFolder());
        MainMenu mainMenu = new MainMenu(menuFolders);

        return mainMenu;
    }

    private MenuItem createFileFolder()
    {
        MenuItem fileFolder = new MenuItem(new Action(FolderIds.fileFolder, "File"d));
        fileFolder.add(new MenuItem(openFileAction));
        fileFolder.add(new MenuItem(saveFileAction));

        return fileFolder;
    }

    private MenuItem createEditFolder()
    {
        MenuItem actionFolder = new MenuItem(new Action(FolderIds.editFolder, "Edit"d));
        actionFolder.add(new MenuItem(runAction));
        actionFolder.add(new MenuItem(settingsAction));

        return actionFolder;
    }
}
