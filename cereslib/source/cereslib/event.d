module cereslib.event;

import std.meta : staticIndexOf, AliasSeq;
import dlib.container.array;

/// A collection of delegates that return void. Should be used to notify somebody about some **event**. `TArgs...` are function arguments
public struct Event(TArgs...)
{
    static assert(staticIndexOf!void == -1,
     "Parameters list can not contain void! use `Event!()` if you want a parameterless event");

    private alias Action = void delegate(TArgs);

    private Array!Action actions;
    private shared Object monitor = new shared Object();

    /// Copy the event from another instance
    /// Params:
    ///   event = the event to be copied
    public this(ref return scope inout Event!(TArgs) event)
    {
        /// Bruh that's a copy CONSTRUCTOR, we must be able to change inout fields
        auto ref immutableSelfActions = cast() actions;
        immutableSelfActions.reserve(event.actions.length);
        
        //Array.opIndex doesn't modify anything but it wasn't declared with inout so I have to cast to mutable here >:(
        auto immutableOtherActions = cast() event.actions;

        for(size_t i = 0; i < immutableOtherActions.length; i++)
        {
            immutableSelfActions ~= immutableOtherActions[i];
        }

        monitor = new shared Object();
    }

    ~this()
    {
        actions.free();
    }

    /// Concatenate an action to the event
    /// Params:
    ///   action = the action to be concatenated
    public void opOpAssign(string op: "~")(Action action) shared
    {
        add(action);
    }

    /// Invoke the event
    void opCall(TArgs params) shared inout
    {
        invoke(params);
    }

    /// Invoke the event
    public void invoke(TArgs params) shared inout
    {
        synchronized(monitor)
        {
            //Array.opApply doesn't modify anything but it wasn't declared with inout so I have to cast to mutable here >:(
            auto ref mutableActions = cast() actions;

            foreach(action; mutableActions)
            {
                action(params);
            }
        }
    }

        /// Concatenate an action to the event
    /// Params:
    ///   action = the action to be concatenated
    public void add(Action action) shared
    {
        synchronized(monitor)
        {
            auto ref actions = cast() actions;
            actions ~= action;
        }
    }

    /// Remove an action from the event
    /// Params:
    ///   action = the action to be removed
    public void remove(Action action) shared
    {        
        synchronized(monitor)
        {
            auto ref actions = cast() actions;
            actions.removeFirst(action);
        }
    }

    public void opOpAssign(string op: "~")(Action action)
    {
        add(action);
    }

    void opCall(TArgs params) inout
    {
        invoke(params);
    }
    
    public void invoke(TArgs params) inout
    {
        //Array.opApply doesn't modify anything but it wasn't declared with inout so I have to cast to mutable here >:(
        auto ref immutableActions = cast() actions;

        foreach(action; immutableActions)
        {
            action(params);
        }
    }
    
    public void add(Action action)
    {
        actions ~= action;
    }

    public void remove(Action action)
    {
        actions.removeFirst(action);
    }
}

unittest
{
    int a = 100;
    bool b = false;

    void foo()
    {
        a = 100_500;
    }

    void bar()
    {
        b = true;
    }

    void buzz()
    {
        assert(false);
    }

    Event!() event;

    event.add(&foo);
    event ~= &bar;
    
    event ~= &buzz;
    event.remove(&buzz);

    event.invoke();
    assert(a == 100_500);
    assert(b);
}

unittest
{
    Event!(int) event;

    void foo(int a)
    {
        assert(a == 42);
    }

    event.add(&foo);
    event(42);
}

unittest
{
    int a;
    void buzz()
    {
        a = 100;
    }

    Event!() event;
    event ~= &buzz;

    const event2 = event;
    event.remove(&buzz);

    event2();
    assert(a == 100);
}

unittest
{
    int a;

    void foo()
    {
        import std.stdio; writeln(a);
        a = 1000;
    }

    shared Event!() event;
    event ~= &foo;

    event.invoke();
    assert(a == 1000);
}