module vm.viewmakers.iviewfactory;

import dlangui;

/// Something that can make a view of something
public interface IViewFactory
{
    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create();
}

public final class DummyViewFactory : IViewFactory
{
    /// Create a view instance
    /// Returns:
    /// a new widget tree inside `parent`
    public Widget create()
    {
        return new Widget("dummyViewWidget");
    }
}