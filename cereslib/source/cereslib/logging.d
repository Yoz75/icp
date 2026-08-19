module cereslib.logging;

public enum LogType : ubyte
{
    /// Unknown type of logging. Default value
    unknown = 0,
    /// Basic information
    info,
    /// Worning log
    warning,
    /// Error log
    error,
    /// Debug log
    debug_
}

/// Mechanism to log some information to every attached loggee.
/// Use version = CereslibEnableBasicLogs to enable logging except debug.
/// Use version = CereslibEnableDebugLogs to enable logging of `LogType.debug_` logs. Debug logs won't work if basic are disabled too
public final class Logger
{
    private ILoggee[] loggees;
    /// Attach a new loggee
    /// Params:
    ///   loggee = 
    public void addLoggee(ILoggee loggee)
    {
        version(CereslibEnableLogs)
        {
            loggees ~= loggee;
        }
    }

    public void log(string text, LogType type = LogType.info)
    {
        version(CereslibEnableLogs)
        {
            version(CereslibEnableDebugLogs) { }
            else
            {
                if(type == LogType.debug_)
                {
                    return;
                }
            }

            string prefix;
            final switch(type)
            {
                case LogType.unknown:
                    prefix = "[UNKNOWN]: ";
                    break;
                case LogType.info:
                    prefix = "[INFO]:";
                    break;
                case LogType.warning:
                    prefix = "[WARNING]:";
                    break;
                case LogType.error:
                    prefix = "[ERROR]:";
                    break;
                case LogType.debug_:
                    prefix = "[DEBUG]:";
                    break;
            }

            auto resultText = prefix ~ text;
            foreach(loggee; loggees)
            {
                loggee.log(resultText, type);
            }
        }
    }
}

/// Something that can log information somewhere
public interface ILoggee
{
    /// Log some text somewhere
    public void log(string text, LogType type);
}

public final class ConsoleLoggee : ILoggee
{
    import std.stdio;

    /// Log some text to console
    public void log(string text, LogType type)
    {
        writeln(text);
    }
}

public final class FileLoggee : ILoggee
{
    import std.file;
    import std.datetime;
    private string logFilePath;

    public this(string logsDirectory)
    {
        logFilePath = logsDirectory ~ '/' ~ "LOG " ~ Clock.currTime.toISOExtString;
    }

    /// Log some text to a file
    public void log(string text, LogType type)
    {
        append(logFilePath, text);
    }
}