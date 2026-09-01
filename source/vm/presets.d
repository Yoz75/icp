module vm.presets;
import icp.image;
import icp.filters;
import dlangui : WidgetGroup;
import vm.filterviews;
import vm.replaceableview;

Preset[] globalRegisteredPresets;

/// An ICP preset: a bunch if filters
public final class Preset
{
    private dstring name_;

    private IFilter[] filters;
    private IReplaceableView[] views;

    public this(dstring name)
    {
        name_ = name;
    }

    public @property dstring name() => name_;

    public void enable(WidgetGroup viewsParent)
    {
        foreach(view; views)
        {
            view.initialize(viewsParent);
        }
    }

    public void disable()
    {
        foreach(view; views)
        {
            view.destroy();
        }
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

public void registerDefaultPresets()
{
    globalRegisteredPresets ~= makePixelizerPreset();
    globalRegisteredPresets ~= makeBnW();
    globalRegisteredPresets ~= makeNothingPreset();
    globalRegisteredPresets ~= makeResizeOnlyPreset();
}

private Preset makeBnW()
{
    Preset bwPreset = new Preset("Uncolorizer");

    auto bwFilter = new BW_Filter();
    bwPreset.filters ~= bwFilter;
    bwPreset.views ~= new BW_FilterView(bwFilter);

    return bwPreset;
}

// I need this to test preset switching
private Preset makeNothingPreset()
{
    Preset nothingPreset = new Preset("Nothing");
    
    auto noFilter = new NoFilter();
    nothingPreset.filters ~= noFilter;
    nothingPreset.views ~= new NoFilterView();

    return nothingPreset;
}

private Preset makeResizeOnlyPreset()
{
    Preset resizeOnlyPreset = new Preset("Resizer");

    auto resizeFilter = new ResizeFilter();
    resizeOnlyPreset.filters ~= resizeFilter;
    resizeOnlyPreset.views ~= new ResizeFilterView(resizeFilter);

    return resizeOnlyPreset;
}

private Preset makePixelizerPreset()
{
    Preset pixelizerPreset = new Preset("Pixelizer");

    auto resizeFilter = new ResizeFilter();
    pixelizerPreset.filters ~= resizeFilter;
    pixelizerPreset.views ~= new ResizeFilterView(resizeFilter);

    auto quantizeFilter = new QuantizeFilter();
    pixelizerPreset.filters ~= quantizeFilter;
    pixelizerPreset.views ~= new QuantizerFilterView(quantizeFilter);

    return pixelizerPreset;
}