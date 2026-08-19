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
