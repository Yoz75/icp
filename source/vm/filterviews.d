/// Module that defines views for filters
module vm.filterviews;
import vm.image;
import icp.filters;
import icp.dithering;
import icp.quantizers;
import vm.replaceableview;
import view;
import std.conv;
import std.string : isNumeric;
import std.path : dirName;
import dlangui;

public final class NoFilterView : IReplaceableView
{
    public void initialize(WidgetGroup group)
    {
        // nothing
    }

    public void destroy()
    {
        // ditto
    }
}

public final class BW_FilterView : IReplaceableView
{
    private static size_t lastId;

    private MultilineTextWidget caption;
    private NumberBox!float strengthNumberBox;
    private WidgetGroup parent;
    private size_t id;

    private BW_Filter filter;

    public this(BW_Filter filter)
    {
        this.filter = filter;
        id = lastId++;
    }

    public void initialize(WidgetGroup group)
    {
        caption = new MultilineTextWidget("bwFilterEditLineCaption", "Discoloration Power"d);

        strengthNumberBox = new NumberBox!float("bwFilterViewEditLine", 0, 1, 0.1, 1);
        strengthNumberBox.layoutWidth = FILL_PARENT;

        strengthNumberBox.numberEdited ~= (float value)
        {
            filter.effectStrength = value;
        };

        group.addChild(caption);
        group.addChild(strengthNumberBox);
        parent = group;
    }

    public void destroy()
    {        
        immutable captionIndex = parent.childIndex(caption);
        assert(captionIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(captionIndex);

        immutable editLineIndex = parent.childIndex(strengthNumberBox);
        assert(editLineIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(editLineIndex);
    }
}

public final class ResizeFilterView : IReplaceableView
{
    private WidgetGroup parent;
    private HorizontalLayout resolutionParent;

    private ResizeFilter filter;

    public this(ResizeFilter filter)
    {
        this.filter = filter;
    }

    public void initialize(WidgetGroup group)
    {
        parent = group;
        resolutionParent = new HorizontalLayout("resizeFilterResolutionParent");

        auto xResolutionLayout = new VerticalLayout("resizeFilterXResolutionLayout");
        auto xResolutionText = new TextWidget("resizeFilterXResolutionText", "Res X"d);
        NumberBox!short xResolutionBox = new NumberBox!short("resizeFilterXResBox", min: 1, defaultValue: 16);

        xResolutionBox.numberEdited ~= (short value)
        {
            filter.resultXResolution = value;
        };

        auto yResolutionLayout = new VerticalLayout("resizeFilterYResolutionLayout");
        auto yResolutionText = new TextWidget("resizeFilterYResolutionText", "Res Y"d);

        NumberBox!short yResolutionBox = new NumberBox!short("resizeFilterYResBox", min: 1, defaultValue: 16);
        yResolutionBox.numberEdited ~= (short value)
        {
            filter.resultYResolution = value;
        };

        xResolutionLayout.addChild(xResolutionText);
        xResolutionLayout.addChild(xResolutionBox);
        resolutionParent.addChild(xResolutionLayout);

        yResolutionLayout.addChild(yResolutionText);
        yResolutionLayout.addChild(yResolutionBox);
        resolutionParent.addChild(yResolutionLayout);

        parent.addChild(resolutionParent);
    }

    public void destroy()
    {
        immutable resolutionIndex = parent.childIndex(resolutionParent);
        assert(resolutionIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(resolutionIndex);
    }
}

public final class QuantizerFilterView : IReplaceableView
{
    private enum SupportedDitherers
    {
        no = 0,
        floydSteinberg,
        sierra3,
        sierra2Row,
        sierraLight,
        rightPropagation,
        randomDitherer
    }

    private enum SupportedQuantizers
    {
        medianSection = 0,
        paletteInjection
    }

    private static final class MedianSectionView : IReplaceableView
    {
        private WidgetGroup parent;
        private VerticalLayout settingsLayout;

        private MedianSectionQuantizer!Palette quantizer;

        public this(MedianSectionQuantizer!Palette quantizer)
        {
            this.quantizer = quantizer;
        }
        
        public void initialize(WidgetGroup group)
        {
            parent = group;
            settingsLayout = new VerticalLayout("medianSectionSettingsLayout");

            auto colorsCountText = new TextWidget("quantizerFilterColorsCountText").text("Colors Count");
            auto colorsCountBox = new NumberBox!uint("quantizerFilterColorsCountNumberBox", min: 2, defaultValue: 8, max: 255);
            colorsCountBox.layoutWidth = FILL_PARENT;
            colorsCountBox.numberEdited ~= (uint value)
            {
                quantizer.colorsCount = value;                
            };

            auto redCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionRedCorrectionNumberBox", 
                                    min: 0, defaultValue: 0.2126f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
            redCorrectionBox.numberEdited ~= (float value)
            {
                quantizer.redCorrectionMultiplier = value;                
            };
            
            auto greenCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionGreenCorrectionNumberBox", 
                                    min: 0, defaultValue: 0.7152f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
            greenCorrectionBox.numberEdited ~= (float value)
            {
                quantizer.greenCorrectionMultiplier = value;
            };

            auto blueCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionBlueCorrectionNumberBox", 
                                    min: 0, defaultValue: 0.0722f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
            blueCorrectionBox.numberEdited ~= (float value)
            {
                quantizer.blueCorrectionMultiplier = value;
            };

            import cereslib.todo; mixin TODO!("Rename rgb correction checkbox text to make it clearer");
            auto useColorCorrectionText = 
            new MultilineTextWidget("medianSectionFilterCoorrectionText").
            text("Color-width correction (median cut)");

            auto useColorCorrectionBox = new CheckBox("medianSectionFilterCorrectionCheckBox");
            useColorCorrectionBox.checkChange = (Widget widget, bool state)
            {
                quantizer.useColorCorrection = state;

                if(state)
                {
                    redCorrectionBox.enable();
                    greenCorrectionBox.enable();
                    blueCorrectionBox.enable();
                }
                else
                {
                    redCorrectionBox.disable();
                    greenCorrectionBox.disable();
                    blueCorrectionBox.disable();
                }
                
                return true;
            };

            parent.addChild(settingsLayout);
            settingsLayout.addChild(colorsCountText);
            settingsLayout.addChild(colorsCountBox);
            settingsLayout.addChild(useColorCorrectionText);
            settingsLayout.addChild(useColorCorrectionBox);
            settingsLayout.addChild(redCorrectionBox);
            settingsLayout.addChild(greenCorrectionBox);
            settingsLayout.addChild(blueCorrectionBox);

            
            //cuz initially color correction disabled
            redCorrectionBox.disable();
            greenCorrectionBox.disable();
            blueCorrectionBox.disable();
        }

        public void destroy()
        {
            immutable layoutIndex = parent.childIndex(settingsLayout);
            assert(layoutIndex > -1, "Oh crap, our widgets were already deleted!");
            parent.removeChild(layoutIndex);
        }
    }

    private static final class CloneView : IReplaceableView
    {
        private WidgetGroup parent;
        private VerticalLayout settingsLayout;
        private string currentFilePath;

        private CloneQuantizer!Palette quantizer;

        public this(CloneQuantizer!Palette quantizer)
        {
            this.quantizer = quantizer;
        }
        
        public void initialize(WidgetGroup group)
        {
            import dlangui.dialogs.dialog;
            import dlangui.dialogs.filedlg;
            
            parent = group;
            settingsLayout = new VerticalLayout("cloneSettingsLayout");

            auto selectImageButton = new Button("cloneSelectImageButton").text("Palette Image..."d);
            selectImageButton.click = (widget)
            {
                auto dialog = new FileDialog(UIString.fromRaw("Open palette source image..."d), parent.window);
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

            parent.addChild(settingsLayout);
            settingsLayout.addChild(selectImageButton);
        }

        public void destroy()
        {
            immutable layoutIndex = parent.childIndex(settingsLayout);
            assert(layoutIndex > -1, "Oh crap, our widgets were already deleted!");
            parent.removeChild(layoutIndex);
        }
    }

    private WidgetGroup parent;
    private VerticalLayout settingsLayout;
    private IReplaceableView quantizerView;

    private QuantizeFilter filter;

    public this(QuantizeFilter filter)
    {
        this.filter = filter;
    }

    public void initialize(WidgetGroup group)
    {
        parent = group;

        settingsLayout = new VerticalLayout("quantizerFilterSettingsLayout");

        import cereslib.todo;
        mixin TODO!"Try to make abstraction for every quantizer. Probably use IReplaceableView";
        
        auto dithererText = new TextWidget("quantizerFilterDithererText").text("Ditherer");
        auto dithererSelector = new StateWidget!SupportedDitherers("quantizerFilterrDithererSelector");
        dithererSelector.stateChanged ~= (SupportedDitherers state)
        {
            with(SupportedDitherers)
            final switch(state)
            {
                case no:
                    filter.ditherer = new NoDitherer!Palette();
                    break;
                case floydSteinberg:
                    filter.ditherer = new FloydSteinbergDitherer!Palette();
                    break;
                case sierra3:
                    filter.ditherer = new SierraThreeDitherer!Palette();
                    break;
                case sierra2Row:
                    filter.ditherer = new SierraTwoRowDitherer!Palette();
                    break;
                case sierraLight:
                    filter.ditherer = new SierraLightDitherer!Palette();
                    break;
                case rightPropagation:
                    filter.ditherer = new RightPropagationDitherer!Palette();
                    break;
                case randomDitherer:
                    filter.ditherer = new RandomDitherer!Palette();
                    break;
            }
        };

        auto quantizerText = new TextWidget("quantizerFilterDithererText").text("Quantizer");
        auto quantizerSelector = new StateWidget!SupportedQuantizers("quantizerFilterrQuantizerSelector");
        quantizerSelector.stateChanged ~= (SupportedQuantizers state)
        {
            if(quantizerView !is null)
                quantizerView.destroy();

            with(SupportedQuantizers)
            final switch(state)
            {
                case medianSection:                    
                    auto quantizer = new MedianSectionQuantizer!Palette();
                    filter.quantizer = quantizer;
                    quantizerView = new MedianSectionView(quantizer);
                    break;
                    
                case paletteInjection:
                    auto quantizer = new CloneQuantizer!Palette();
                    filter.quantizer = quantizer;
                    quantizerView = new CloneView(quantizer);
                    break;
            }

            quantizerView.initialize(parent);
        };

        parent.addChild(settingsLayout);
        settingsLayout.addChild(dithererText);
        settingsLayout.addChild(dithererSelector);
        settingsLayout.addChild(quantizerText);
        settingsLayout.addChild(quantizerSelector);

        quantizerView = new MedianSectionView(cast(MedianSectionQuantizer!Palette) filter.quantizer);
        quantizerView.initialize(parent);
    }

    public void destroy()
    {
        immutable layoutIndex = parent.childIndex(settingsLayout);
        assert(layoutIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(layoutIndex);
    }
}

private class NoDithererView : IReplaceableView
{
    public void initialize(WidgetGroup group)
    {
        // nothing
    }

    public void destroy()
    {
        // ditto``
    }
}