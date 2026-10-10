module view.stateframelayout;
import std.traits : isSomeString;
import dlangui;

/// `FrameLayout` witch content depends on current state
public class StateFrameLayout(T) : FrameLayout
{
    private string[T] state2ChildId;

    this() 
    {
        this(null);
    }

    this(string ID)
    {
        super(ID);
    }

    public void addChild(Widget child, T childState)
    {
        assert(child.id !is null && child.id.length > 0, "child id must NOT be null!");
        assert((childState in state2ChildId) is null, "State is already presented in states!");
        super.addChild(child);
        state2ChildId[childState] = child.id;
    }

    /// Set current frame's state
    /// Params:
    ///   state = the state to be set
    public void changeState(T state)
    {
        assert((state in state2ChildId) !is null, "State wasn't presented in states!");
        string childId = state2ChildId[state];

        showChild(childId);
    }
}