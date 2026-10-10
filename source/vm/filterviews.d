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

/// A replaceable view without content. Used when you don't want to add parameters but have to use IReplaceableView cuz of boilerplate
public final class DummyView : IReplaceableView
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
    private enum defaultResolution = 256;

    private WidgetGroup parent;
    private VerticalLayout settingsLayout;

    private ResizeFilter filter;
    private int[2] currentResolution = [defaultResolution, defaultResolution];

    public this(ResizeFilter filter)
    {
        this.filter = filter;
    }

    public void initialize(WidgetGroup group)
    {
        parent = group;
        settingsLayout = new VerticalLayout("resizeFilterSettingsLayout");        
        auto absoluteResolutionParent = new HorizontalLayout("resizeFilterResolutionParent");

        auto resolutionPercentageRadioButton = new RadioButton("resizeFilterResResizeModeRadioButton").text(UIString.fromId("ResizeFilterView_resolutionPercentageRadioButton"));
        resolutionPercentageRadioButton.checked = true;
        auto resolutionCustomRadioButton = new RadioButton("resizeFilterResResizeModeRadioButton").text(UIString.fromId("ResizeFilterView_resolutionCustomRadioButton"));

        auto percentageResolutionText = new TextWidget("resizeFilterPercentageResizeText", "Image scale (%):"d);
        NumberBox!float percentageResolutionBox = new NumberBox!float("resizeFilterXResBox", min: 1f, defaultValue: 100f);
        percentageResolutionBox.numberEdited ~= (float value)
        {
            filter.resultPercentageResolution = value;
        };

        auto xResolutionLayout = new VerticalLayout("resizeFilterXResolutionLayout");
        auto xResolutionText = new TextWidget("resizeFilterXResolutionText", "ResizeFilterView_xResolutionText");
        NumberBox!short xResolutionBox = new NumberBox!short("resizeFilterXResBox", min: 1, defaultValue: defaultResolution);

        xResolutionBox.numberEdited ~= (short value)
        {
            currentResolution[0] = value;
            filter.resultResolution = currentResolution;
        };

        auto yResolutionLayout = new VerticalLayout("resizeFilterYResolutionLayout");
        auto yResolutionText = new TextWidget("resizeFilterYResolutionText", "ResizeFilterView_yResolutionText");
        NumberBox!short yResolutionBox = new NumberBox!short("resizeFilterYResBox", min: 1, defaultValue: defaultResolution);
        yResolutionBox.numberEdited ~= (short value)
        {
            currentResolution[1] = value;
            filter.resultResolution = currentResolution;
        };

        resolutionPercentageRadioButton.click = (widget)
        {
            xResolutionText.enabled = false;
            yResolutionText.enabled = false;

            xResolutionBox.enabled = false;
            yResolutionBox.enabled = false;

            percentageResolutionText.enabled = true;
            percentageResolutionBox.enable();

            return true;
        };

        resolutionCustomRadioButton.click = (widget)
        {
            xResolutionText.enabled = true;
            yResolutionText.enabled = true;

            xResolutionBox.enabled = true;
            yResolutionBox.enabled = true;

            percentageResolutionText.enabled = false;
            percentageResolutionBox.disable();

            return true;
        };

        settingsLayout.addChild(resolutionPercentageRadioButton);
        settingsLayout.addChild(resolutionCustomRadioButton);
        settingsLayout.addChild(percentageResolutionText);
        settingsLayout.addChild(percentageResolutionBox);

        settingsLayout.addChild(absoluteResolutionParent);
        xResolutionLayout.addChild(xResolutionText);
        xResolutionLayout.addChild(xResolutionBox);
        absoluteResolutionParent.addChild(xResolutionLayout);

        yResolutionLayout.addChild(yResolutionText);
        yResolutionLayout.addChild(yResolutionBox);
        absoluteResolutionParent.addChild(yResolutionLayout);

        //cuz initially we don't use them
        xResolutionText.enabled = false;
        yResolutionText.enabled = false;

        xResolutionBox.disable();
        yResolutionBox.disable();

        parent.addChild(settingsLayout);
    }

    public void destroy()
    {
        immutable resolutionIndex = parent.childIndex(settingsLayout);
        assert(resolutionIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(resolutionIndex);
    }
}

/*public final class QuantizerFilterView : IReplaceableView
{



    private WidgetGroup parent;
    private VerticalLayout settingsLayout;

    private FrameLayout dithererViewParent, quantizerViewParent;
    private IReplaceableView dithererView;
    private IReplaceableView quantizerView;

    /// Parent for ditherers without parameters
    private WidgetGroup parameterlessDithererParent;
    private WidgetGroup bayerDithereParent;
    private WidgetGroup randomDithererParent;

    private enum parameterlessDithererParentId = "quantizerFilterParameterlessDithererParent";
    private enum bayerDithererParentId = "quantizerFilterBayerDithererParent";
    private enum randomDithererParentId = "quantizerFilterRandomDithererParent";

    private WidgetGroup medianSectionQuantizerParent;
    private WidgetGroup cloneQuantizerParent;

    private enum medianSectionQuantizerParentId = "quantizerFilterMedianSectionQuantizerParent";
    private enum cloneQuantizerParentId = "quantizerFilterCloneQuantizerParent";

    private QuantizeFilter filter;

    public this(QuantizeFilter filter)
    {
        this.filter = filter;
    }

    public void initialize(WidgetGroup group)
    {
        parent = group;
        settingsLayout = new VerticalLayout("quantizerFilterSettingsLayout");
        
        auto dithererText = new TextWidget("quantizerFilterDithererText").textResource("QuantizerFilterView_ditherer");
        auto dithererSelector = new StateWidget!SupportedDitherers("quantizerFilterDithererSelector");
        dithererSelector.stateChanged ~= (SupportedDitherers state)
        {
            if(dithererView !is null)
                dithererView.destroy();

            with(SupportedDitherers)
            final switch(state)
            {
                case no:
                    filter.ditherer = new NoDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case bayerMatrix:
                auto ditherer = new BayerDitherer!Palette();
                    filter.ditherer = ditherer;
                    dithererView = new BayerDithererView(ditherer);
                    break;
                case floydSteinberg:
                    filter.ditherer = new FloydSteinbergDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case sierra3:
                    filter.ditherer = new SierraThreeDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case sierra2Row:
                    filter.ditherer = new SierraTwoRowDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case sierraLight:
                    filter.ditherer = new SierraLightDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case rightPropagation:
                    filter.ditherer = new RightPropagationDitherer!Palette();
                    dithererView = new DummyView();
                    break;
                case randomDitherer:
                    auto ditherer = new RandomDitherer!Palette();
                    filter.ditherer = ditherer;
                    dithererView = new RandomDithererView(ditherer);
                    break;
            }

            dithererView.initialize(dithererViewParent);
        };

        dithererViewParent = new FrameLayout("quantizerFilterDithererViewParent");
        dithererViewParent.layoutHeight = FILL_PARENT;
        dithererViewParent.layoutWeight = FILL_PARENT;

        auto quantizerText = new TextWidget("quantizerFilterDithererText").textResource("QuantizerFilterView_quantizer");
        auto quantizerSelector = new StateWidget!SupportedQuantizers("quantizerFilterQuantizerSelector");
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

            quantizerView.initialize(quantizerViewParent);
        };

        quantizerViewParent = new FrameLayout("quantizerFilterQuantizerViewParent");
        quantizerViewParent.layoutHeight = FILL_PARENT;
        quantizerViewParent.layoutWeight = FILL_PARENT;

        parent.addChild(settingsLayout);
        settingsLayout.addChild(dithererText);
        settingsLayout.addChild(dithererSelector);
        settingsLayout.addChild(dithererViewParent);
        settingsLayout.addChild(quantizerText);
        settingsLayout.addChild(quantizerSelector);
        settingsLayout.addChild(quantizerViewParent);

        quantizerView = new MedianSectionView(cast(MedianSectionQuantizer!Palette) filter.quantizer);
        quantizerView.initialize(quantizerViewParent);
    }

    public void destroy()
    {
        immutable layoutIndex = parent.childIndex(settingsLayout);
        assert(layoutIndex > -1, "Oh crap, our widgets were already deleted!");
        parent.removeChild(layoutIndex);
    }

    /// Create parents of ditherers
    /// Params:
    ///   parent = the parent of every ditherer's parent
    private void createDithererParents(WidgetGroup parent)
    {
        parameterlessDithererParent = new VerticalLayout(parameterlessDithererParentId);
        bayerDithereParent = new VerticalLayout(bayerDithererParentId);
        randomDithererParent = new VerticalLayout(randomDithererParentId);

        parent.addChild(parameterlessDithererParent);
        parent.addChild(bayerDithereParent);
        parent.addChild(randomDithererParent);
    }

    /// Create parents of quantizers
    /// Params:
    ///   parent = the parent of every quantizers's parent
    private void createQuantizerParanets(WidgetGroup parent)
    {
        medianSectionQuantizerParent = new VerticalLayout(medianSectionQuantizerParentId);
        cloneQuantizerParent = new VerticalLayout(cloneQuantizerParentId);

        parent.addChild(medianSectionQuantizerParent);
        parent.addChild(cloneQuantizerParent);
    }
}*/