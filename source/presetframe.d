/// It would be strange to put it:
/// in view cuz view shouldn't know about `Preset`
/// in preset cuz preset shouldn't know we use `StateFrameLayout`
/// in app.d cuz it already bloated as hell
module presetframe;

import vm.presets;
import view.stateframelayout;
import dlangui;
import dlangui.widgets.metadata;

shared static this()
{
    mixin(registerWidgetMetadataClass!PresetFrameLayout);
}


/// An `StateFrameLayout(T)` instance espesially for using in DML
public final class PresetFrameLayout : StateFrameLayout!Preset
{
    this() 
    {
         this(null);
    }

    this(string ID) 
    {
        super(ID);
    }
}