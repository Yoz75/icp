module cereslib.properties;
import std.traits : getUDAs, Unqual;

struct min(T)
{
    T value;
}

struct max(T)
{
    T value;
}


/// Template for fast getter maker. 
/// Params:
///   Field = the field
///   name = the name of the getter. Default is the `Field`s name without the last character
mixin template MakeGetter(alias Field, string name = __traits(identifier, Field)[0..$-1])
{
    mixin("@property auto " ~ name ~ "() => " ~ __traits(identifier, Field) ~ ";");
}


mixin template MakeSetter(alias Field, string name = __traits(identifier, Field)[0..$-1])
{
    import std.traits : getUDAs, Unqual;
    enum fieldName = __traits(identifier, Field);
    alias FieldType = typeof(Field);

    mixin("@property void " ~ name ~ "(" ~ FieldType.stringof ~ " newValue)
        {
            static if (getUDAs!(Field, cereslib.properties.min!FieldType).length != 0)
            {
                newValue = newValue < getUDAs!(Field, cereslib.properties.min!(typeof(Field)))[0].value
                    ? getUDAs!(Field, cereslib.properties.min)[0].value
                    : newValue;
            }

            static if (getUDAs!(Field, cereslib.properties.max!FieldType).length != 0)
            {
                newValue = newValue > getUDAs!(Field, cereslib.properties.max!(typeof(Field)))[0].value
                    ? getUDAs!(Field, cereslib.properties.max)[0].value
                    : newValue;
            }

            " ~ fieldName ~ " = newValue;
        }"
    );
}

unittest
{
    struct Test
    {
        private @min!float(5.5f) float value_;
        private @max!uint(4u) uint value2_;

        mixin MakeGetter!value_;
        mixin MakeSetter!value_;

        mixin MakeGetter!value2_;
        mixin MakeSetter!value2_;
    }

    Test test;

    test.value = 2.0f;
    assert(test.value == 5.5f);

    test.value = 10.0f;
    assert(test.value == 10.0f);

    test.value2 = 100;
    assert(test.value2 == 4);
}