module view.statewidget;

import cereslib.event;
import std.traits;
import std.conv;
import dlangui;

/// Provides a state to the class instance
/// Needed because std.conv.to(T) works with classes pretty bad
public interface IStateProvider(T)
{
    public dstring getState() inout;
    public T toState(in dstring state) inout;
}

// I wanted this to be WidgetGroupDefaultDrawing, but at some fucking reason it doesnt draw children/
// Why the fuck they named it DEFAULT DRAWING?????
/// Widget that allows user to select state T from a states range
/// If T is a enum, all it's fields will be available
/// Else, T MUST have toString() and fromString(string) methods
public final class StateWidget(T) : HorizontalLayout 
if(is(T == enum) ||
   isSomeString!T ||
   (__traits(compiles, { string str = T.init.toString(); }) &&
    __traits(compiles, { T t = T.init.fromString(string.init); })))
{
    static assert(!is(T == struct), 
     "Sorry, currently StateWidget doesn't support structs as state type. Use class, string or enum instead.");

    /// Invokes when state changes.
    public Event!(T) stateChanged;

    private T state;
    private ComboBox stateSelectorBox;
    private T[] availableStates;

    public this(string id)
    {
        super(id);
        layoutHeight = 25;
        initialize();
    }
    
    static if(is(T == enum)) {}    
    else static if(is(T == dstring))
    {
        public this(string id, T[] states)
        {
            this(id);
            initialize();
            
            stateSelectorBox.items = states;
        }
    }
    else
    {        
        public this(string id, T[] states)
        {
            this(id);

            //availableStates = states;
            dstring names = dstring[states.length];
            foreach(i, state; states)
            {
                static if(isSomeString!T)
                {
                    names[i] = state.to!dstring;
                }
                else
                {
                    names[i] = state.toString();
                }
            }

            stateSelectorBox.items = names;
        }
    }

    private void initialize()
    {
        stateSelectorBox = new ComboBox(_id ~ "StateSelectorBox");

        stateSelectorBox.itemClick = (widget, int index)
        {        
            immutable name = stateSelectorBox.items[index].value;

            static if(is(T == dstring))
            {
                stateChanged(name);
            }
            else static if(isSomeString!T || is(T == enum))
            {
                auto state = name.to!T;
                stateChanged(state);
            }
            else
            {
                auto state = T.toState(name);
                stateChanged(state);
            }

            return true;
        };

        // enums have limited states count so we can just iterate over them
        // btw we assume user can select ANY state of the enum (y the wouldn't?)
        static if(is(T == enum))
        {
            dstring[] enumNames = new dstring[__traits(allMembers, T).length];
            foreach (i, name; __traits(allMembers, T))
            {
                enumNames[i] = name.to!dstring;
            }

            stateSelectorBox.items = enumNames;
        }

        addChild(stateSelectorBox);
    }
}
