module windows.settings;

import settings;import dlangui;
import dlangui.widgets.winframe;

/// Creates and initializes the settings window
public final class SettingsWindow
{
    private dstring title;
    private Window parent;

    public this(dstring title, Window parent)
    {
        this.title = title;
    }

    public void show()
    {
        auto window = Platform.instance.createWindow(title, parent);
        initializeContent(window);
        window.show();
    }

    private void initializeContent(Window window)
    {
        window.mainWidget = parseML(import("settingsWindow.dml"));

        auto settingsLayout = window.mainWidget.childById!FrameLayout("settingsLayout");

        auto personalizationButton = window.mainWidget.childById!Button("persinalizationSettingsButton");
        personalizationButton.click = (widget)
        {
            settingsLayout.showChild("personalizationSettingsLayout");
            return true;
        };

        
        auto generalButton = window.mainWidget.childById!Button("generalSettingsButton");
        generalButton.click = (widget)
        {
            settingsLayout.showChild("generalSettingsLayout");
            return true;
        };


        setupGeneralLayout(settingsLayout);
        setupPersonalizationLayout(settingsLayout);
        


        settingsLayout.showChild("personalizationSettingsLayout");
    }

    private void setupPersonalizationLayout(FrameLayout settingsLayout)
    {
        import cereslib.todo; mixin TODO!"Remove enums and add some registrar to registrer custom themes";
        enum darkNeoThemeName = "Dark Neo";
        enum darkNeoThemeId = "theme_neo_dark";

        enum darkThemeName = "Dark";
        enum darkThemeId = "theme_dark_fixed";

        enum lightThemeName = "Light";
        enum lightThemeId = "theme_default_fixed";

        auto personalizationLayout = settingsLayout.childById!VerticalLayout("personalizationSettingsLayout");
        auto themeComboBox = personalizationLayout.childById!ComboBox("themeSelectionComboBox");
        themeComboBox.itemClick = (widget, int index)
        {        
            immutable name = themeComboBox.items[index].value;

            switch(name)
            {
                case darkNeoThemeName:
                    Platform.instance.uiTheme = darkNeoThemeId;
                    Settings.instance.selectedTheme = darkNeoThemeId;
                    break;

                case darkThemeName:
                    Platform.instance.uiTheme = darkThemeId;
                    Settings.instance.selectedTheme = darkThemeId;
                    break;

                case lightThemeName:
                    Platform.instance.uiTheme = lightThemeId;
                    Settings.instance.selectedTheme = lightThemeId;
                    break;
                default:
                    throw new Exception("Unknown theme!");
            }

            return true;
        };
    }

    private void setupGeneralLayout(FrameLayout settingsLayout)
    {
        auto generalLayout = settingsLayout.childById!VerticalLayout("generalSettingsLayout");

        auto cleanupGCCheckbox = generalLayout.childById!CheckBox("cleanupGCCheckbox");
        cleanupGCCheckbox.checked = Settings.instance.shouldCleanGCMemoryOnDone;
        cleanupGCCheckbox.checkChange = (Widget widget, bool state)
        {
            Settings.instance.shouldCleanGCMemoryOnDone = state;
            return true;
        };
    }
}