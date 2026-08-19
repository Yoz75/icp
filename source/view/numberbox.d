module view.numberbox;
import cereslib.event;
import std.conv : to;
import std.traits : isNumeric;
import std.string : isNumeric;
import std.algorithm : clamp;
import dlangui;

/// An Edit Line and 2 buttons, can only contain numbers
public final class NumberBox(T) : HorizontalLayout if(isNumeric!T)
{
    invariant
    {
        assert(min < T.max, "Min value can not be " ~ T.stringof ~ ".max!");
        assert(defaultValue < T.max, "Default value can not be " ~ T.stringof ~ ".max!");
        assert(step < T.max, "Step can not be " ~ T.stringof ~ ".max!");
        assert(defaultValue >= min && defaultValue <= max, "Default value is not in [min, max] bounds!");
    }

    alias NumberEditedAction = void delegate(T newValue);

    /// Invokes when number was edited (you can invoke it manually, but why?)
    public Event!T numberEdited;

    immutable T min, max;
    immutable T defaultValue = 0;

    public T step = 1;

    private EditLine editLine;
    private VerticalLayout buttonsLayout;

    private T currentValue = 0;

    public this(string id, T min = T.max, T max = T.max, T step = T.max, T defaultValue = T.max)
    {
        super(id);

        if(min == T.max)
        {
            // floating point types do not have .min property!!!
            static if(__traits(compiles, T.min))
            {
                this.min = T.min;
            }
            else
            {
                this.min = -T.max;
            }
        }
        else
        {
            this.min = min;
        }

        max == T.max ? (this.max = T.max) : (this.max = max);
        defaultValue == T.max ? (this.defaultValue = 0) : (this.defaultValue = defaultValue);
        step == T.max ? (this.step = 1) : (this.step = step);

        layoutHeight = 25;
        initializeChildren();
    }

    /// Initialize the number box
    private void initializeChildren()
    {
        editLine = cast(EditLine) new EditLine(id ~ "_editLine").layoutWidth(FILL_PARENT);
        editLine.text = defaultValue.to!dstring;
        currentValue = defaultValue;
        
        editLine.editorAction = (const Action action)
        {
            dstring currentText = editLine.text;

            if(!currentText.isNumeric)
            {
                editLine.text = defaultValue.to!dstring;
                currentValue = defaultValue;

                numberEdited(value);
                return true;
            }

            setValue(currentText.to!T);
            return true;
        };

        buttonsLayout = cast(VerticalLayout) new VerticalLayout(id ~ "_buttonsLayout");

        auto increaseButton = new Button(id ~ "_increaseButton", "+"d).margins(0).padding(0);
        increaseButton.click = (widget)
        {
            // int promoution!!
            setValue(cast(T) (currentValue + step));
            return true;
        };

        auto decreaseButton = new Button(id ~ "_decreaseButton", "-"d).margins(0).padding(0);
        decreaseButton.click = (widget)
        {
            //ditto!
            setValue(cast(T) (currentValue - step));
            numberEdited(currentValue);
            return true;
        };

        addChild(editLine);
        addChild(buttonsLayout);

        buttonsLayout.addChild(increaseButton);
        buttonsLayout.addChild(decreaseButton);
    }

    public T value() => editLine.text.to!T;

    public void enable()
    {
        immutable count = buttonsLayout.childCount;
        foreach(i; 0..count)
        {
            auto child = buttonsLayout.child(i);
            child.enabled = true;
        }

        editLine.enabled = true;
    }

    public void disable()
    {
        immutable count = buttonsLayout.childCount;
        foreach(i; 0..count)
        {
            auto child = buttonsLayout.child(i);
            child.enabled = false;
        }

        editLine.enabled = false;
    }

    private void setValue(T value)
    {
        currentValue = value.clamp(min, max);

        editLine.text = currentValue.to!dstring;
        numberEdited(currentValue);
    }
}