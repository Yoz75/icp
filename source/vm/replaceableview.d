module vm.replaceableview;
import dlangui;

/// Some Widget that can be easily replaced with another one at runtime
public interface IReplaceableView
{
    /// Initialize the view and add it to the `group`
    public void initialize(WidgetGroup group);

    /// Destroy the group, uninitialize it
    public void destroy();
}