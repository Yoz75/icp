/// Module that defines views for filters
module vm.filterviews;
import icp.filters;
import icp.dithering;
import icp.quantizers;
import vm.replaceableview;
import view;
import std.conv;
import std.string : isNumeric;
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
        rightPropagation
    }

    private enum SupportedQuantizers
    {
        medianSection = 0,
        clonePalette
    }

    private WidgetGroup parent;
    private VerticalLayout settingsLayout;

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
            }
        };

        auto quantizerText = new TextWidget("quantizerFilterDithererText").text("Quantizer");
        auto quantizerSelector = new StateWidget!SupportedQuantizers("quantizerFilterrQuantizerSelector");
        quantizerSelector.stateChanged ~= (SupportedQuantizers state)
        {
            with(SupportedQuantizers)
            final switch(state)
            {
                case medianSection:
                    filter.quantizer = new MedianSectionQuantizer!Palette();
                    break;
                case clonePalette:

                    break;
            }
        };

        auto colorsCountText = new TextWidget("quantizerFilterColorsCountText").text("Colors Count");
        auto colorsCountBox = new NumberBox!uint("quantizerFilterColorsCountNumberBox", min: 2, defaultValue: 8, max: 255);
        colorsCountBox.layoutWidth = FILL_PARENT;
        colorsCountBox.numberEdited ~= (uint value)
        {
            if(cast(MedianSectionQuantizer!Palette)filter.quantizer !is null)
            {
                auto medianSection = cast(MedianSectionQuantizer!Palette) filter.quantizer;
                medianSection.colorsCount = value;
            }
        };

        auto redCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterRedCorrectionNumberBox", 
                                min: 0, defaultValue: 0.2126f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        redCorrectionBox.numberEdited ~= (float value)
        {
            if(cast(MedianSectionQuantizer!Palette)filter.quantizer !is null)
            {
                auto medianSection = cast(MedianSectionQuantizer!Palette) filter.quantizer;
                medianSection.redCorrectionMultiplier = value;
            }
        };
        
        auto greenCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterGreenCorrectionNumberBox", 
                                min: 0, defaultValue: 0.7152f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        greenCorrectionBox.numberEdited ~= (float value)
        {
            if(cast(MedianSectionQuantizer!Palette)filter.quantizer !is null)
            {
                auto medianSection = cast(MedianSectionQuantizer!Palette) filter.quantizer;
                medianSection.greenCorrectionMultiplier = value;
            }
        };

        auto blueCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterBlueCorrectionNumberBox", 
                                min: 0, defaultValue: 0.0722f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        blueCorrectionBox.numberEdited ~= (float value)
        {
            if(cast(MedianSectionQuantizer!Palette)filter.quantizer !is null)
            {
                auto medianSection = cast(MedianSectionQuantizer!Palette) filter.quantizer;
                medianSection.blueCorrectionMultiplier = value;
            }
        };

        import cereslib.todo; mixin TODO!("Rename rgb correction checkbox text to make it clearer");
        auto useColorCorrectionText = 
         new MultilineTextWidget("medianSectionFilterCoorrectionText").
         text("Color-width correction (median cut)");

        auto useColorCorrectionBox = new CheckBox("medianSectionFilterCorrectionCheckBox");
        useColorCorrectionBox.checkChange = (Widget widget, bool state)
        {
           if(cast(MedianSectionQuantizer!Palette)filter.quantizer !is null)
            {
                auto medianSection = cast(MedianSectionQuantizer!Palette) filter.quantizer;
                medianSection.useColorCorrection = state;

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
            }
            return true;
        };

        //туду: сделать квантайзер-копирщик цветов

        parent.addChild(settingsLayout);
        settingsLayout.addChild(dithererText);
        settingsLayout.addChild(dithererSelector);
        settingsLayout.addChild(quantizerText);
        settingsLayout.addChild(quantizerSelector);
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