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
    /// The selected theme
    @JsonizeField private string selectedTheme_ = "theme_neo_dark";
    /// The selected locale
    @JsonizeField private string selectedLocale_ = "en";
    /// At witch ratio result image should be rendered with bilinear interpolation?
    @JsonizeField private float pointInterpolationThreshold_ = 1f;

    private static string filePath;

    public static this()
    {
        filePath = buildPath(getcwd(), fileName);
    }

    public static void loadOrSetDefault()
    {
        loadOrSave!Settings(filePath, instance);
    }

    /// Should the program clean GC memory when done?
    public @property bool shouldCleanGCMemoryOnDone() => shouldCleanGCMemoryOnDone_;

    /// Should the program clean GC memory when done?
    public @property void shouldCleanGCMemoryOnDone(bool value)
    {
        shouldCleanGCMemoryOnDone_ = value;
        save();
    }

    /// The selected theme
    public @property string selectedTheme() => selectedTheme_;

    /// The selected theme
    public @property void selectedTheme(string value)
    {
        selectedTheme_ = value;
        save();
    }

    /// The selected locale
    public @property string selectedLocale() => selectedLocale_;
    /// The selected locale
    public @property void selectedLocale(string value)
    {
        selectedLocale_ = value;
        save();
    }

    /// At witch ratio result image should be rendered with bilinear interpolation?
    public @property float pointInterpolationThreshold() => pointInterpolationThreshold_;
    
    /// At witch ratio result image should be rendered with bilinear interpolation?
    public @property void pointInterpolationThreshold(float value)
    {
        pointInterpolationThreshold_ = value;
        save();
    }

    private void save()
    {
        saveToFile!Settings(filePath, instance);
    }
}