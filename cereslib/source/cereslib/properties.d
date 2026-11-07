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

/// Dummy function to use as default parameter in templates
pragma(inline, true)
private void dummyFunction()
{

}

/// Template to quickly make getters. 
/// Params:
///   Field = the field
///   name = the name of the getter. Default is the `Field`s name without the last character
mixin template MakeGetter(alias field, string name = __traits(identifier, field)[0..$-1])
{
    mixin("@property auto " ~ name ~ "() => " ~ __traits(identifier, field) ~ ";");
}


/// Template to quickly make setters.
/// Params:
///   field = the field
///   onSetSuccessfully = the `void delegate()` invoked when successfully set the `Field`
///   name = the name of the setter. Default is the `Field`s name without the last character
mixin template MakeSetter(alias field, alias onSetSuccessfully = dummyFunction, string name = __traits(identifier, field)[0..$-1])
{
    import std.traits : getUDAs, Unqual;
    enum fieldName = __traits(identifier, field);
    alias FieldType = typeof(field);

    mixin("@property void " ~ name ~ "(" ~ FieldType.stringof ~ " newValue)
        {
            static if (getUDAs!(field, cereslib.properties.min!FieldType).length != 0)
            {
                newValue = newValue < getUDAs!(field, cereslib.properties.min!(FieldType))[0].value
                    ? getUDAs!(field, cereslib.properties.min)[0].value
                    : newValue;
            }

            static if (getUDAs!(field, cereslib.properties.max!FieldType).length != 0)
            {
                newValue = newValue > getUDAs!(field, cereslib.properties.max!(FieldType))[0].value
                    ? getUDAs!(field, cereslib.properties.max)[0].value
                    : newValue;
            }

            " ~ fieldName ~ " = newValue;
            onSetSuccessfully();
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