module view.messagebox;

import dlangui;

/// Logs warnings and errors as messages
public final class TextMessageBox
{
    private Window parent;

    public this(Window parentWindow)
    {
        parent = parentWindow;
    }
    
    /// Show the box
    /// Params:
    ///   textId = 
    public void show(string textId)
    {
        show(UIString.fromId(textId).value);        
    }

    /// Show the box with `text`
    /// Params:
    ///   text = the text to be shown
    public void show(dstring text)
    {
        parent.showMessageBox(UIString.fromRaw("An error occured:"d), UIString.fromRaw(text.to!dstring));
    }
}