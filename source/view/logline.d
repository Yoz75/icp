module view.logline;

import std.container.dlist;
import std.conv;
import dlangui;

/// A status line for logs. It saves some entries and allows to move between them
public final class LogLine : StatusLine
{
    private uint logsCapacity;
    private uint currentLogIndex;
    private uint logsCount;

    invariant
    {
       assert(logsCount <= logsCapacity);
    }

    private DList!dstring logsQueue;

    private Button prevLogButton, nextLogButton;

    public this(uint logsCapacity)
    {
        this.logsCapacity = logsCapacity;
        super();
    }

    public override void setStatusText(dstring value)
    {
        super.setStatusText(value);

        logsQueue ~= value;
        logsCount++;

        if(logsCount > logsCapacity)
        {
            logsQueue.removeBack();
            logsCount = logsCapacity;
        }
    }

    protected override void initialize()
    {
        super.initialize();
        prevLogButton = cast(Button) new Button(_id ~ "PrevLogButton").text("prev");
        prevLogButton.click = (Widget unused)
        {
            showPreviousLog();
            return true;
        };

        nextLogButton = cast(Button) new Button(_id ~ "PrevLogButton").text("next");
        nextLogButton.click = (Widget unused)
        {
            showNextLog();
            return true;
        };

        addChild(prevLogButton);
        addChild(nextLogButton);
    }

    private void showPreviousLog()
    {
        currentLogIndex--;
        boundIndex();

        _defStatus.text = "[" ~ currentLogIndex.to!dstring ~ "] " ~ logsQueue.atIndex(currentLogIndex);
    }

    private void showNextLog()
    {
        currentLogIndex++;
        boundIndex();

        _defStatus.text = "[" ~ currentLogIndex.to!dstring ~ "] " ~ logsQueue.atIndex(currentLogIndex);
    }

    private void boundIndex()
    {
        if(currentLogIndex < 0) currentLogIndex = 0;
        if(currentLogIndex >= logsCount) currentLogIndex = logsCount - 1;
    }
}

/// Get an
/// Params:
///   list = 
///   index = 
/// Returns: element at index `index` or T.init
private T atIndex(T)(DList!T list, size_t index)
{
    size_t i;
    foreach(ref element; list)
    {
        if(i == index)
        {
            return element;
        }

        i++;
    }

    return T.init;
}