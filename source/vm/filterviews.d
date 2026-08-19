/// Module that defines views for filters
module vm.filterviews;
import icp.filters;
import icp.dithering;
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

public final class MedianSectionFilterView : IReplaceableView
{
    private enum SupportedDitherers
    {
        no,
        rightPropagation,
        floydSteinberg
    }

    private WidgetGroup parent;
    private VerticalLayout settingsLayout;

    private MedianSectionFilter filter;

    public this(MedianSectionFilter filter)
    {
        this.filter = filter;
    }

    public void initialize(WidgetGroup group)
    {
        parent = group;

        settingsLayout = new VerticalLayout("medianSectionFilterSettingsLayout");
        
        auto dithererText = new TextWidget("medianSectionDithererText").text("Ditherer");
        auto dithererSelector = new StateWidget!SupportedDitherers("medianSectionFilterDithererSelector");
        dithererSelector.stateChanged ~= (SupportedDitherers state)
        {
            final switch(state)
            {
                case SupportedDitherers.no:
                    filter.ditherer = null;
                    break;
                case SupportedDitherers.rightPropagation:
                    filter.ditherer = new RightPropagationDitherer();
                    break;
                case SupportedDitherers.floydSteinberg:
                    filter.ditherer = new FloydSteinbergDitherer();
                    break;
            }
        };

        auto colorsCountText = new TextWidget("medianSectionColorsCountText").text("Colors Count");
        auto colorsCountBox = new NumberBox!uint("medianSectionFilterColorsCountNumberBox", min: 2, defaultValue: 8);
        colorsCountBox.layoutWidth = FILL_PARENT;
        colorsCountBox.numberEdited ~= (uint value)
        {
            filter.colorsCount = value;
        };

        auto redCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterRedCorrectionNumberBox", 
                                min: 0, defaultValue: 0.2126f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        redCorrectionBox.numberEdited ~= (float value)
        {
            filter.redCorrectionMultiplier = value;
        };
        
        auto greenCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterGreenCorrectionNumberBox", 
                                min: 0, defaultValue: 0.7152f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        greenCorrectionBox.numberEdited ~= (float value)
        {
            filter.greenCorrectionMultiplier = value;
        };

        auto blueCorrectionBox = cast(NumberBox!float) new NumberBox!float("medianSectionFilterBlueCorrectionNumberBox", 
                                min: 0, defaultValue: 0.0722f, max: 2, step: 0.05f).layoutWidth(FILL_PARENT);
        blueCorrectionBox.numberEdited ~= (float value)
        {
            filter.blueCorrectionMultiplier = value;
        };

        import cereslib.todo; mixin TODO!("Rename rgb correction checkbox text to make it clearer");
        auto useColorCorrectionText = 
         new MultilineTextWidget("medianSectionFilterCoorrectionText").
         text("Color-width correction (median cut)");

        auto useColorCorrectionBox = new CheckBox("medianSectionFilterCorrectionCheckBox");
        useColorCorrectionBox.checkChange = (Widget widget, bool state)
        {
            filter.useColorCorrection = state;

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
        settingsLayout.addChild(dithererText);
        settingsLayout.addChild(dithererSelector);
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
        // ditto
    }
}