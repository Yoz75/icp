module vm.viewmakers.quantizers;

public import icp.filters.quantizefilter;
import vm.image;
import vm.viewmakers.iviewfactory;
import view;
import std.path;
import dlangui;

public enum SupportedQuantizers
{
    medianSection = 0,
    paletteInjection
}

public final class MedianSectionQuantizerViewFactory : IViewFactory
{
    private MedianSectionQuantizer!Palette quantizer;
    public this(MedianSectionQuantizer!Palette quantizer)
    {
        this.quantizer = quantizer;
    }
    
    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        auto settingsLayout = parseML!VerticalLayout(import("medianSectionView.dml"));
        auto colorsCountBox = settingsLayout.childById!IntBox("colorsCountBox");
        colorsCountBox.numberEdited ~= (int value)
        {
            quantizer.colorsCount = value;                
        };

        auto redCorrectionBox = settingsLayout.childById!FloatBox("redCorrectionBox");
        redCorrectionBox.numberEdited ~= (float value)
        {
            quantizer.redCorrectionMultiplier = value;                
        };
        
        auto greenCorrectionBox = settingsLayout.childById!FloatBox("greenCorrectionBox");
        greenCorrectionBox.numberEdited ~= (float value)
        {
            quantizer.greenCorrectionMultiplier = value;
        };

        auto blueCorrectionBox = settingsLayout.childById!FloatBox("blueCorrectionBox");
        blueCorrectionBox.numberEdited ~= (float value)
        {
            quantizer.blueCorrectionMultiplier = value;
        };

        auto useColorCorrectionBox = settingsLayout.childById!CheckBox("useColorCorrectionBox");
        useColorCorrectionBox.checkChange = (Widget widget, bool state)
        {
            quantizer.useColorCorrection = state;
            if(state)
            {
                redCorrectionBox.enabled = true;
                greenCorrectionBox.enabled = true;
                blueCorrectionBox.enabled = true;
            }
            else
            {
                redCorrectionBox.enabled = false;
                greenCorrectionBox.enabled = false;
                blueCorrectionBox.enabled = false;
            }
            
            return true;
        };

        //cuz initially color correction disabled
        redCorrectionBox.disable();
        greenCorrectionBox.disable();
        blueCorrectionBox.disable();

        return settingsLayout;
    }
}

public final class CloneQuantizerViewFactory : IViewFactory
{
    private CloneQuantizer!Palette quantizer;
    public this(CloneQuantizer!Palette quantizer)
    {
        this.quantizer = quantizer;
    }
    
    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        import dlangui.dialogs.dialog;
        import dlangui.dialogs.filedlg;
        string currentFilePath;

        auto settingsLayout = new VerticalLayout("cloneSettingsLayout");
        auto selectImageButton = new Button("cloneSelectImageButton").textResource("CloneView_selectImageButton");
        selectImageButton.click = (widget)
        {
            auto dialog = new FileDialog(UIString.fromId("CloneView_dialogueHeader"), null);
            dialog.styleId = "ICP_DEFAULT_LAYOUT";
            dialog.addFilter(FileFilterEntry(UIString.fromRaw("(png|jpg|bmp|tga)"d),
            "*.png;*.jpg;*.jpeg;*.bmp;*.tga"));
            if(currentFilePath.length > 0)
            {
                dialog.path = currentFilePath.dirName;
            }

            dialog.dialogResult = (Dialog unused, const Action action)
            {
                currentFilePath = action.stringParam;
                if(currentFilePath is null) return;

                auto image = loadImageFrom(currentFilePath);
                if(!image.hasValue)
                {
                    import applogger;
                    globalAppLogger.log("Couldn't load a palette-source image, Try resaving it.", LogType.error);
                    return;
                }
                quantizer.sourceImage = image.value;
            };
            dialog.show();
            return true;
        };
        settingsLayout.addChild(selectImageButton);

        return settingsLayout;
    }
}