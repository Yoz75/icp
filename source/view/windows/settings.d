module view.windows.settings;

import view;
import settings;
import applogger;
import cereslib.todo;
import std.conv : to;
import dlangui;

/// Creates and initializes the settings window
public final class SettingsWindowFactory : IWindowFactory
{
    public Window create(dstring title, Window parent)
    {
        auto window = Platform.instance.createWindow(title, parent);
        initializeContent(window);

        return window;
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
        auto personalizationLayout = settingsLayout.childById!VerticalLayout("personalizationSettingsLayout");

        /*
            Well, actually, it would be faster here to 
        */
        void setupThemeComboBox()
        {
            mixin TODO!"Remove enums and add some registrar to registrer custom themes";

            
            enum darkNeoThemeIndex = 0;
            enum darkNeoThemeId = "theme_neo_dark";

            enum darkThemeIndex = 1;
            enum darkThemeId = "theme_dark_fixed";

            enum lightThemeIndex = 2;
            enum lightThemeId = "theme_default_fixed";

            auto themeComboBox = personalizationLayout.childById!ComboBox("themeSelectionComboBox");
            themeComboBox.itemClick = (widget, index)
            {
                switch(index)
                {
                    case darkNeoThemeIndex:
                        Platform.instance.uiTheme = darkNeoThemeId;
                        Settings.instance.selectedTheme = darkNeoThemeId;
                        break;

                    case darkThemeIndex:
                        Platform.instance.uiTheme = darkThemeId;
                        Settings.instance.selectedTheme = darkThemeId;
                        break;

                    case lightThemeIndex:
                        Platform.instance.uiTheme = lightThemeId;
                        Settings.instance.selectedTheme = lightThemeId;
                        break;

                    default:
                        globalAppLogger.log("Unknown theme: "
                         ~ themeComboBox.items[index].value.to!string, LogType.error);
                        break;
                }

                return true;
            };
        }

        void setupLocalizationComboBox()
        {
            enum englishLocalizationIndex = 0;
            enum englishLocalizationId = "en";

            enum russianLocalizationIndex = 1;
            enum russianLocalizationId = "ru";

            auto localizationComboBox = personalizationLayout.childById!ComboBox("localizationSelectionComboBox");
            localizationComboBox.itemClick = (widget, index)
            {
                switch(index)
                {
                    case englishLocalizationIndex:
                        Platform.instance.uiLanguage = englishLocalizationId;
                        Settings.instance.selectedLocale = englishLocalizationId;
                        break;
                    case russianLocalizationIndex:
                        Platform.instance.uiLanguage = russianLocalizationId;
                        Settings.instance.selectedLocale = russianLocalizationId;
                        break;
                    default:
                        globalAppLogger.log("Unknown localization name: "
                         ~ localizationComboBox.items[index].value.to!string, LogType.error);
                        break;
                }

                return true;
            };
        }

        mixin TODO!"Replace combo boxes here with state widgets";
        
        setupThemeComboBox();
        setupLocalizationComboBox();
    }

    private void setupGeneralLayout(FrameLayout settingsLayout)
    {
        auto generalLayout = settingsLayout.childById!VerticalLayout("generalSettingsLayout");

        void setupCleanupCheckbox()
        {
            auto cleanupGCCheckbox = generalLayout.childById!CheckBox("cleanupGCCheckbox");
            cleanupGCCheckbox.checked = Settings.instance.shouldCleanGCMemoryOnDone;
            cleanupGCCheckbox.checkChange = (Widget widget, bool state)
            {
                Settings.instance.shouldCleanGCMemoryOnDone = state;
                return true;
            };
        }

        void setupPointInterpolationThresholdCheckbox()
        {
            auto thresholdBox = generalLayout.childById!FloatBox("pointInterpolationThresholdBox");
            thresholdBox.numberEdited ~= (float value)
            {
                Settings.instance.pointInterpolationThreshold = value;
            };
        }

        setupCleanupCheckbox();
        setupPointInterpolationThresholdCheckbox();
    }
}