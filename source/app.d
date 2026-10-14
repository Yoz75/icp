import settings;
import vm;
import view;
import applogger;
import presetframe;
import cereslib.versions;
import std.sumtype : has, get;
import std: getcwd, chainPath, array, to, dirName;
import dlangui;
import dlangui.dialogs.filedlg : FileDialog, FileFilterEntry, FileDialogFlag;
import dlangui.dialogs.dialog : Dialog;

mixin APP_ENTRY_POINT;

extern(C) int UIAppMain(string[] args)
{
    programVersion = Version.fromString(import("version.txt"));
    Settings.loadOrSetDefault();
        
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    Platform.instance.uiTheme = Settings.instance.selectedTheme;

    immutable width = 800;
    immutable height = 600;
    Window window = Platform.instance.createWindow("ICP " ~ programVersion.toDstring(), null, WindowFlag.Resizable, width, height);
    window.windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;

    auto frame = new MainFrame();
    window.mainWidget = frame;

    globalAppLogger = new Logger();
    globalAppLogger.addLoggee(new StatusLineLoggee(frame.statusLine));
    globalAppLogger.addLoggee(new FileLoggee(chainPath(getcwd(), "Logs").array));

    window.show();
    return Platform.instance.enterMessageLoop();
}

// I don't like the idea of actions but i have to use them🫩
enum ActionIds : int
{
    openFileAction = 100_000,
    saveFileAction,
    saveAsFileAction,
    runAction,
    settingsAction
}

private final class MainFrame : AppFrame
{
    /// path to the last open file
    private string currentOpenFilePath, currentSaveFilePath;
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
            case openFileAction:   openFile();           break;
            case saveFileAction:   saveFile();           break;
            case saveAsFileAction: saveAsFile();         break;
            case runAction:        run();                break;
            case settingsAction:   openSettingsWindow(); break;
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

        auto presetView = body.childById!PresetFrameLayout("presetView");
        auto presetsComboBox = body.childById!ComboBox("presetsComboBox");

        import cereslib.todo; mixin TODO!"Move registerDefaultPresets call from her to outside";
        registerDefaultPresets(presetView);

        // bruh dlangui lets me assign a value to items but doesn't let me append >:(
        dstring[] presetNames = new dstring[globalRegisteredPresets.length];
        foreach(i, preset; globalRegisteredPresets)
        {
            presetNames[i] = preset.name;
            preset.viewParent.requestLayout();
            presetView.addChild(preset.viewParent, preset);
        }

        icp.selectPreset(globalRegisteredPresets[0]);
        presetView.changeState(globalRegisteredPresets[0]);

        presetsComboBox.items = presetNames;

        presetsComboBox.itemClick = (widget, int index)
        {        
            immutable name = presetsComboBox.items[index].value;

            //oh god linear search!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            foreach(preset; globalRegisteredPresets)
            {
                if(preset.name == name)
                {
                    icp.selectPreset(preset);
                    presetView.changeState(preset);
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

        if(currentOpenFilePath.length > 0)
        {
           dialog.path = currentOpenFilePath.dirName;
        }
        
        dialog.dialogResult = (Dialog unused, const Action action)
        {
            currentOpenFilePath = action.stringParam;
        };

        dialog.show();
    }

    import cereslib.todo;
    mixin TODO!"Separate save and saveAsFile to its own class so these methods only call that class methods";

    private void saveFile()
    {
        if(currentSaveFilePath is null || currentSaveFilePath == "")
        {
            saveAsFile();            
        }
        else
        {
            icp.save(currentImage, currentSaveFilePath);
            globalAppLogger.log("Saved image correctly", LogType.info);
        }
    }

    private void saveAsFile()
    {
        if(currentImage is null) return;
        auto dialog = new FileDialog(UIString.fromRaw("Save image..."d), 
        window, fileDialogFlags: FileDialogFlag.Save | FileDialogFlag.EnableCreateDirectory);
        dialog.styleId = "ICP_DEFAULT_LAYOUT";
        dialog.filename = "save.png";

        dialog.dialogResult = (Dialog unused, const Action action)
        {
            if(action.stringParam is null || action.stringParam == "")
            {
                return;
            }

            currentSaveFilePath = action.stringParam;

            try
            {
                icp.save(currentImage, action.stringParam);
                globalAppLogger.log("Saved image correctly at " ~ currentSaveFilePath, LogType.info);
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
        if(currentOpenFilePath.length <= 0) 
        {
            enum openFileZeroLengthError = "MainFrame_openFileZeroLengthWarning"c;
            globalAppLogger.log("currentOpenFilePath length is zero, skipped running", LogType.warning);

            auto box = new TextMessageBox(window);
            box.show(openFileZeroLengthError);
            return;
        }

        try
        {
            auto buffer = icp.process(currentOpenFilePath);
            
            if(!buffer.hasValue)
            {
                string error = buffer.error;

                globalAppLogger.log(error, LogType.error);

                auto box = new TextMessageBox(window);
                box.show(error);

                return;
            }

            currentImage = buffer.value;
            preview.imageBuffer = currentImage;
        }
        catch(Exception ex)
        {
            globalAppLogger.log("An error occured: " ~ ex.message.to!string, LogType.error);

            auto box = new TextMessageBox(window);
            box.show(ex.message.to!dstring);
        }

        globalAppLogger.logGCMemory();
        if(Settings.instance.shouldCleanGCMemoryOnDone)
        {
            // During processing, ICP allocates a lot of stuff
            globalAppLogger.log("Calling GC.collect() and GC.minimize()...");
            import core.memory; GC.collect(); GC.minimize();
            globalAppLogger.logGCMemory();
        }
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
     = new Action(ActionIds.openFileAction, "MainMenuMaker_openFileAction"c).addAccelerator(KeyCode.F6)
                                                             .addAccelerator(KeyCode.KEY_O, KeyFlag.Control);
    const Action saveFileAction 
     = new Action(ActionIds.saveFileAction, "MainMenuMaker_saveFileAction"c).addAccelerator(KeyCode.F7)
                                                             .addAccelerator(KeyCode.KEY_S, KeyFlag.Control);

    const Action saveAsFileAction 
     = new Action(ActionIds.saveAsFileAction, "MainMenuMaker_saveAsFileAction"c).addAccelerator(KeyCode.F7, KeyFlag.Shift)
                                                             .addAccelerator(KeyCode.KEY_S, KeyFlag.Control | KeyFlag.Shift);
    const Action runAction
     = new Action(ActionIds.runAction, "MainMenuMaker_runAction"c).addAccelerator(KeyCode.F5)
                                              .addAccelerator(KeyCode.KEY_F, KeyFlag.Control);
    const Action settingsAction
     = new Action(ActionIds.settingsAction, "MainMenuMaker_settingsAction"c).addAccelerator(KeyCode.F13)
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
        MenuItem fileFolder = new MenuItem(new Action(FolderIds.fileFolder, "MainMenuMaker_fileFolder"c));
        fileFolder.add(new MenuItem(openFileAction));
        fileFolder.add(new MenuItem(saveFileAction));
        fileFolder.add(new MenuItem(saveAsFileAction));

        return fileFolder;
    }

    private MenuItem createEditFolder()
    {
        MenuItem editFolder = new MenuItem(new Action(FolderIds.editFolder, "MainMenuMaker_editFolder"c));
        editFolder.add(new MenuItem(runAction));
        editFolder.add(new MenuItem(settingsAction));

        return editFolder;
    }
}
