module renotify.druntime_symbols;

extern (C) __gshared private:

version (unittest) {}
else:

// Dummy symbols
immutable void* D12TypeInfo_Aya6__initZ;
immutable void* D14TypeInfo_Const6__vtblZ;
immutable void* D15TypeInfo_Struct6__vtblZ;
immutable void* D8renotify4core7__arrayZ;
immutable void* D8renotify8renotify15__unittest_failFiZv;
immutable void* D8renotify8renotify7__arrayZ;
immutable void* D8renotify9container10hash_table8__assertFiZv;
immutable void* D8renotify9container5array7__arrayZ;
immutable void* D8renotify9container5array8__assertFiZv;
immutable void* D8renotify9container6common8__assertFiZv;
immutable void* _D8renotify4core7__arrayZ;
immutable void* _D8renotify8renotify7__arrayZ;
immutable void* _D12TypeInfo_Aya6__initZ;
immutable void* _D18TypeInfo_Invariant6__vtblZ;
immutable void* _d_assert_msg;
immutable void* __dmd_personality_v0;

void[] _d_arraycopy(size_t size, void[] from, void[] to)
{
    import core.stdc.string : memcpy;
    // enforceRawArraysConformable("copy", size, from, to);
    memcpy(to.ptr, from.ptr, to.length * size);
    return to;
}

void __assert(const char *msg, const char *file, int line)
{
    assert(false);
}
