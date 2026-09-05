module vm.logging;
public import cereslib.logging;
import std.conv;
import dlangui;

/// Logs information in a `StatusLine`
public final class StatusLineLoggee : ILoggee
{
    private StatusLine line;
    public this(StatusLine line)
    {
        this.line = line;
    }

    /// Logs some text to a `TextWidget`
    public void log(string text, LogType type)
    {
        line.setStatusText(text.to!dstring);
    }
}

/// Logs warnings and errors as messages
public final class ErrorMessageBoxLogging : ILoggee
{
    private Window parent;

    public this(Window parentWindow)
    {
        parent = parentWindow;
    }

    /// Logs some text to a `TextWidget`
    public void log(string text, LogType type)
    {
        if(type == LogType.error || type == LogType.warning)
        {
            showErrorBox(text);
        }
    }

    private void showErrorBox(string text)
    {
        parent.showMessageBox(UIString.fromRaw("An error occured:"d), UIString.fromRaw(text.to!dstring));
    }
}