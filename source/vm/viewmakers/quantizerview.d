module vm.viewmakers.quantizerview;

import vm.viewmakers.iviewfactory;
import vm.viewmakers.quantizers;
import vm.viewmakers.ditherers;
import view;
import dlangui;

/// View factory that makes views for a `QuantizerFilter`
public final class QuantizeFilterViewFactory : IViewFactory
{
    private BayerDitherer!Palette bayerDitherer;
    private RandomDitherer!Palette randomDitherer;

    private FloydSteinbergDitherer!Palette floydSteinbergDitherer;
    private SierraThreeDitherer!Palette sierra3Ditherer;
    private SierraTwoRowDitherer!Palette sierra2RowDitherer;
    private SierraLightDitherer!Palette sierraLightDitherer;
    private RightPropagationDitherer!Palette rightPropagationDitherer;
    private NoDitherer!Palette noDitherer;

    private MedianSectionQuantizer!Palette medianSectionQuantizer;
    private CloneQuantizer!Palette cloneQuantizer;

    private QuantizeFilter filter;

    public this(QuantizeFilter filter)
    {
        this.filter = filter;
    }

    /// Create a quantizer view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        createDitherers();
        createQuantizers();

        LinearLayout settingsLayout = new LinearLayout("quantizerSettingsLayout");

        filter.ditherer = noDitherer;
        auto dithererText = new TextWidget("quantizerDithererText").textResource("QuantizerView_ditherer");
        auto dithererFrame = createDithererFrame();
        auto dithererSelector = new StateWidget!SupportedDitherers("quantizerDithererSelector");

        dithererSelector.stateChanged ~= (SupportedDitherers state)
        {
            with(SupportedDitherers)
            final switch(state)
            {
                case no:               filter.ditherer = noDitherer;               break;
                case bayerMatrix:      filter.ditherer = bayerDitherer;            break;
                case floydSteinberg:   filter.ditherer = floydSteinbergDitherer;   break;
                case sierra3:          filter.ditherer = sierra3Ditherer;          break;
                case sierra2Row:       filter.ditherer = sierra2RowDitherer;       break;
                case sierraLight:      filter.ditherer = sierraLightDitherer;      break;
                case rightPropagation: filter.ditherer = rightPropagationDitherer; break;
                case randomDitherer:   filter.ditherer = this.randomDitherer;      break;
            }

            dithererFrame.changeState(state);
        };

        filter.quantizer = medianSectionQuantizer;
        auto quantizerText = new TextWidget("quantizerDithererText").textResource("QuantizerView_quantizer");
        auto quantizerFrame = createQuantizerFrame();        
        auto quantizerSelector = new StateWidget!SupportedQuantizers("quantizerQuantizerSelector");

        quantizerSelector.stateChanged ~= (SupportedQuantizers state)
        {
            with(SupportedQuantizers)
            final switch(state)
            {
                case medianSection:    filter.quantizer = medianSectionQuantizer; break;
                case paletteInjection: filter.quantizer = cloneQuantizer;         break;
            }

            quantizerFrame.changeState(state);
        };

        settingsLayout.addChild(dithererText);
        settingsLayout.addChild(dithererSelector);
        settingsLayout.addChild(dithererFrame);

        settingsLayout.addChild(quantizerText);
        settingsLayout.addChild(quantizerSelector);
        settingsLayout.addChild(quantizerFrame);

        return settingsLayout;
    }

    private void createDitherers()
    {
        bayerDitherer = new BayerDitherer!Palette();
        randomDitherer = new RandomDitherer!Palette();

        noDitherer = new NoDitherer!Palette();
        floydSteinbergDitherer = new FloydSteinbergDitherer!Palette();
        sierra3Ditherer = new SierraThreeDitherer!Palette();
        sierra2RowDitherer = new SierraTwoRowDitherer!Palette();
        sierraLightDitherer = new SierraLightDitherer!Palette();
        rightPropagationDitherer = new RightPropagationDitherer!Palette();
    }

    private void createQuantizers()
    {
        medianSectionQuantizer = new MedianSectionQuantizer!Palette();
        cloneQuantizer = new CloneQuantizer!Palette();
    }

    private StateFrameLayout!SupportedDitherers createDithererFrame()
    {
        auto dummyFactory = new DummyViewFactory();
        auto bayerView = new BayerDithererViewFactory(bayerDitherer).create();
        auto randomView = new RandomDithererViewFactory(randomDitherer).create();

        auto dithererFrame = new StateFrameLayout!SupportedDitherers("quantizerDithererFrame");

        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.no);
        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.floydSteinberg);
        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.sierra3);
        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.sierra2Row);
        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.sierraLight);
        dithererFrame.addChild(dummyFactory.create(), SupportedDitherers.rightPropagation);

        dithererFrame.addChild(randomView, SupportedDitherers.randomDitherer);
        dithererFrame.addChild(bayerView, SupportedDitherers.bayerMatrix);

        dithererFrame.changeState(SupportedDitherers.no);
        return dithererFrame;
    }

    private StateFrameLayout!SupportedQuantizers createQuantizerFrame()
    {
        auto medianSectionView = new MedianSectionQuantizerViewFactory(medianSectionQuantizer).create();
        auto cloneQuantizerView = new CloneQuantizerViewFactory(cloneQuantizer).create();

        auto quantizerFrame = new StateFrameLayout!SupportedQuantizers("quantizerQuantuzerFrame");

        quantizerFrame.addChild(medianSectionView, SupportedQuantizers.medianSection);
        quantizerFrame.addChild(cloneQuantizerView, SupportedQuantizers.paletteInjection);

        quantizerFrame.changeState(SupportedQuantizers.medianSection);
        return quantizerFrame;
    }
}