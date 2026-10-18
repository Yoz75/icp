module view.windows.windowfactory;

import dlangui: Window;

/// Something, that creates and initializes a window
public interface IWindowFactory
{
    /// Create a window with `title` and `parent`
    /// Params:
    ///    title = the window's title
    ///    parent = the parent of the window (null = no parent)
    public Window create(dstring title, Window parent);
}