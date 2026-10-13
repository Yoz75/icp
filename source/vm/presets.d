module vm.presets;
import icp.image;
import icp.filters;
import dlangui : Widget, WidgetGroup, parseML, VerticalLayout;
import vm.viewmakers;
import vm.replaceableview;
import std : to;

Preset[] globalRegisteredPresets;

/// An ICP preset: a bunch if filters
public final class Preset
{
    private string name_;

    private IFilter[] filters;
    private WidgetGroup viewParent_;

    public this(string name, WidgetGroup viewParentParent)
    {
        name_ = name;
        // cuz WidgetGroup is not registered
        viewParent_ = cast(WidgetGroup) parseML!VerticalLayout(import("presetViewParent.dml"));
        viewParent_.id = name;

        viewParentParent.addChild(viewParent_);
    }

    public @property dstring name() => name_.to!dstring;
    public @property WidgetGroup viewParent() => viewParent_;

    public void addFilter(IFilter filter, Widget view = null)
    {
        filters ~= filter;
        if(view !is null) viewParent_.addChild(view);
    }

    public Image process(Image input)
    {
        foreach (IFilter filter; filters)
        {
            input = filter.filter(input);
        }

        return input;
    }

    /*
        todo:
        parsing from string:

        1 Name
        2 then N times:
            Filter class name
            [view Filter view class name] or [init constructor arguments]
    */
}

/// Registers default presets in `globalRegisterPresets` calling this function multiple times results in multiple preset clones XD
public void registerDefaultPresets(WidgetGroup parent)
{
    globalRegisteredPresets ~= makePixelizerPreset(parent);
    globalRegisteredPresets ~= makeBnW(parent);
    globalRegisteredPresets ~= makeNothingPreset(parent);
    globalRegisteredPresets ~= makeResizeOnlyPreset(parent);
}

private Preset makeBnW(WidgetGroup parent)
{
    Preset bwPreset = new Preset("Uncolorizer", parent);

    auto bwFilter = new BW_Filter();
    bwPreset.addFilter(bwFilter, new BW_FilterViewFactory(bwFilter).create());

    return bwPreset;
}

// I need this to test preset switching
private Preset makeNothingPreset(WidgetGroup parent)
{
    Preset nothingPreset = new Preset("Nothing", parent);
    
    auto noFilter = new NoFilter();
    nothingPreset.addFilter(noFilter);

    return nothingPreset;
}

private Preset makeResizeOnlyPreset(WidgetGroup parent)
{
    Preset resizeOnlyPreset = new Preset("Resizer", parent);

    auto resizeFilter = new ResizeFilter();
    resizeOnlyPreset.addFilter(resizeFilter, new ResizeFilterViewFactory(resizeFilter).create());

    return resizeOnlyPreset;
}

private Preset makePixelizerPreset(WidgetGroup parent)
{
    //туду: почему-то падает прога и виджет назван pixelizer такшо наверное тут  проблемиа?????? дебаг
    Preset pixelizerPreset = new Preset("Pixelizer", parent);

    auto resizeFilter = new ResizeFilter();
    pixelizerPreset.addFilter(resizeFilter, new ResizeFilterViewFactory(resizeFilter).create());

    auto quantizeFilter = new QuantizeFilter();    
    pixelizerPreset.addFilter(quantizeFilter, new QuantizeFilterViewFactory(quantizeFilter).create());

    return pixelizerPreset;
}