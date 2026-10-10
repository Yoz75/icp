module vm.viewmakers.resizerview;

import icp.filters.resizefilter;
import vm.viewmakers.iviewfactory;
import view;
import dlangui;

public final class ResizeFilterViewFactory : IViewFactory
{
    private ResizeFilter filter;
    private enum defaultResolution = 256;

    public this(ResizeFilter filter)
    {
        this.filter = filter;
    }

    public Widget create()
    {
        int[2] currentResolution = [defaultResolution, defaultResolution];
 
        auto settingsLayout = new VerticalLayout("settingsLayout");        
        auto absoluteResolutionParent = new HorizontalLayout("resolutionParent");

        auto resolutionPercentageRadioButton = new RadioButton("resResizeModeRadioButton").text(UIString.fromId("ResizerView_resolutionPercentageRadioButton"));
        resolutionPercentageRadioButton.checked = true;
        auto resolutionCustomRadioButton = new RadioButton("resResizeModeRadioButton").text(UIString.fromId("ResizerView_resolutionCustomRadioButton"));

        auto percentageResolutionText = new TextWidget("resizeFilterPercentageResizeText", "Image scale (%):"d);
        auto percentageResolutionBox = new FloatBox("resizeFilterXResBox", min: 1f, defaultValue: 100f);
        percentageResolutionBox.numberEdited ~= (float value)
        {
            filter.resultPercentageResolution = value;
        };

        auto xResolutionLayout = new VerticalLayout("xResolutionLayout");
        auto xResolutionText = new TextWidget("xResolutionText", "ResizerView_xResolutionText");
        auto xResolutionBox = new IntBox("xResBox", min: 1, defaultValue: defaultResolution);

        xResolutionBox.numberEdited ~= (int value)
        {
            currentResolution[0] = value;
            filter.resultResolution = currentResolution;
        };

        auto yResolutionLayout = new VerticalLayout("yResolutionLayout");
        auto yResolutionText = new TextWidget("yResolutionText", "ResizerView_yResolutionText");
        auto yResolutionBox = new IntBox("yResBox", min: 1, defaultValue: defaultResolution);
        yResolutionBox.numberEdited ~= (int value)
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

        return settingsLayout;
    }
}