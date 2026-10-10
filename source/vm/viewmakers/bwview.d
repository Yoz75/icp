module vm.viewmakers.bwview;

import vm.viewmakers.iviewfactory;
import icp.filters.bwfilter;
import view;
import dlangui;

public final class BW_FilterViewFactory : IViewFactory
{
    private BW_Filter filter;

    public this(BW_Filter filter)
    {
        this.filter = filter;
    }

    public Widget create()
    {
        auto settingsLayout = new VerticalLayout("bwSettingsLayout");
        auto caption = new MultilineTextWidget("editLineCaption", "Discoloration Power"d);

        auto strengthNumberBox = new FloatBox("streingEditLine", 0, 1, 0.1, 1);
        strengthNumberBox.layoutWidth = FILL_PARENT;

        strengthNumberBox.numberEdited ~= (float value)
        {
            filter.effectStrength = value;
        };

        settingsLayout.addChild(caption);
        settingsLayout.addChild(strengthNumberBox);

        return settingsLayout;
    }
}