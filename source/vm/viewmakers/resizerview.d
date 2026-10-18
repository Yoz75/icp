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

        auto percentageResolutionText = new TextWidget("resizeFilterPercentageResizeText", "ResizerView_percetnageResolutionText");
        auto percentageResolutionBox = new FloatBox("resizeFilterXResBox", min: 1f, defaultValue: 100f);
        percentageResolutionBox.numberEdited ~= (float value)
        {
            filter.resultPercentageResolution = value;
        };

        auto xResolutionBox = new IntBox("xResBox", min: 1, defaultValue: defaultResolution);

        xResolutionBox.numberEdited ~= (int value)
        {
            currentResolution[0] = value;
            filter.resultResolution = currentResolution;
        };

        auto yResolutionBox = new IntBox("yResBox", min: 1, defaultValue: defaultResolution);
        yResolutionBox.numberEdited ~= (int value)
        {
            currentResolution[1] = value;
            filter.resultResolution = currentResolution;
        };

        resolutionPercentageRadioButton.click = (widget)
        {
            xResolutionBox.enabled = false;
            yResolutionBox.enabled = false;

            percentageResolutionText.enabled = true;
            percentageResolutionBox.enable();

            return true;
        };

        resolutionCustomRadioButton.click = (widget)
        {
            xResolutionBox.enabled = true;
            yResolutionBox.enabled = true;

            percentageResolutionText.enabled = false;
            percentageResolutionBox.disable();

            return true;
        };

        settingsLayout.addChild(resolutionPercentageRadioButton);
        settingsLayout.addChild(percentageResolutionBox);

        settingsLayout.addChild(resolutionCustomRadioButton);
        settingsLayout.addChild(absoluteResolutionParent);
        //xResolutionLayout.addChild(xResolutionBox);
        absoluteResolutionParent.addChild(xResolutionBox);

        //yResolutionLayout.addChild(yResolutionBox);
        absoluteResolutionParent.addChild(yResolutionBox);

        xResolutionBox.disable();
        yResolutionBox.disable();

        return settingsLayout;
    }
}