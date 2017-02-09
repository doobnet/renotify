module renotify.core;

static import config;

void log(Args...)(const char* fmt, Args args)
{
    import core.stdc.stdio : fopen, fprintf, fclose;

    static if (is(typeof(config.logPath)) && config.logPath.length > 0)
    {
        auto file = fopen(config.logPath, "a");
        fprintf(file, fmt, args);
        fclose(file);
    }
}

@safe pure @nogc nothrow:

T find(alias pred, T)(const(T)[] array)
{
    foreach (e ; array)
        if (pred(e))
            return e;

    return T.init;
}

unittest
{
    static immutable array = [1, 2, 3];

    assert(array.find!(e => e > 2) == 3);
    assert(array.find!(e => e > 3) == int.init);
}

bool startsWith(const(char)[] a, const(char)[] b)
{
    return b.length <= a.length ? a[0 .. b.length] == b : false;
}

unittest
{
    assert("foo".startsWith("foo"));
    assert("foobar".startsWith("foo"));
    assert(!"foo".startsWith("bar"));
}

inout(char)[] fromStringz(inout(char)* str) @system
{
    import core.stdc.string : strlen;
    return str ? str[0 .. strlen(str)] : null;
}
