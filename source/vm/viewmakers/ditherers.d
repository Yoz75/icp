module vm.viewmakers.ditherers;

public import icp.filters.quantizefilter;
import vm.viewmakers.iviewfactory;
import view;
import dlangui;

public enum SupportedDitherers
{
    no = 0,
    bayerMatrix,
    floydSteinberg,
    sierra3,
    sierra2Row,
    sierraLight,
    rightPropagation,
    randomDitherer
}

public final class BayerDithererViewFactory : IViewFactory
{
    private BayerDitherer!Palette ditherer;

    public this(BayerDitherer!Palette ditherer)
    {
        this.ditherer = ditherer;
    }

    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        auto settingsLayout = parseML!VerticalLayout(import("bayerDithererView.dml"));

        auto levelBox = settingsLayout.childById!IntBox("levelBox");
        levelBox.numberEdited ~= (int value)
        {
            ditherer.matrixLevel = value;       
        };
        
        return settingsLayout;
    }
}

public final class RandomDithererViewFactory : IViewFactory
{
    private RandomDitherer!Palette ditherer;

    public this(RandomDitherer!Palette ditherer)
    {
        this.ditherer = ditherer;
    }

    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        auto settingsLayout = parseML!VerticalLayout(import("randomDithererView.dml"));
        
        auto randomnessBox = settingsLayout.childById!FloatBox("randomnessBox");
        randomnessBox.numberEdited ~= (float value)
        {
            ditherer.spreading = value;                
        };
        
        return settingsLayout;
    }
}