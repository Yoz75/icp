module settings;

import applogger;
import cereslib.jsonutils;
import std.path : buildPath;
import std.file : getcwd;

/// All settings of the icp!
public struct Settings
{
    mixin MakeJsonizable;
    public static Settings instance;

    private enum fileName = "settings.json";

    /// Should the program clean GC memory when done?
    @JsonizeField private bool shouldCleanGCMemoryOnDone_ = true;
    @JsonizeField private string selectedTheme_ = "theme_neo_dark";

    private static string filePath;

    public static this()
    {
        filePath = buildPath(getcwd(), fileName);
    }

    public static void loadOrSetDefault()
    {
        loadOrSave!Settings(filePath, instance);
    }

    public @property bool shouldCleanGCMemoryOnDone() => shouldCleanGCMemoryOnDone_;
    public @property void shouldCleanGCMemoryOnDone(bool value)
    {
        shouldCleanGCMemoryOnDone_ = value;
        save();
    }

    public @property string selectedTheme() => selectedTheme_;
    public @property void selectedTheme(string value)
    {
        selectedTheme_ = value;
        save();
    }

    private void save()
    {
        saveToFile!Settings(filePath, instance);
    }
}