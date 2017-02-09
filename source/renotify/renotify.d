module renotify.renotify;

import core.stdc.stdio : FILENAME_MAX;
import core.stdc.stdlib : exit, EXIT_FAILURE;

import core.sys.linux.sys.inotify;
import core.sys.posix.dlfcn : dlsym;

import renotify.core;
import renotify.path_map;
import renotify.druntime_symbols;
static import config;

extern (C) alias InotifyAddWatch = int function(int, const char*, uint);
extern (C) alias Read = ptrdiff_t function(int, void*, size_t);

static assert(is(typeof(config.pathMaps)), "Missing pathMaps config");

void loadSymbol(T)(ref T func, const char* name)
{
    enum RTLD_NEXT = cast(void*) -1L;

    if (!func)
    {
        func = cast(T) dlsym(RTLD_NEXT, name);

        if (!func)
        {
            log("Failed to load symbol: %s\n", name);
            exit(EXIT_FAILURE);
        }
    }
}

int inotifyFileDescriptor = -1;

extern (C) int inotify_add_watch(int fd, const char* pathname, uint mask)
{
    static InotifyAddWatch func;

    loadSymbol(func, "inotify_add_watch");

    const mappedPath = pathname.mapWatchPath;
    immutable result = func(fd, mappedPath, mask);

    log("inotify_add_watch(fd: %d, pathname: %s, mappedPath: %s,mask: %d), result: %d\n", fd,
        pathname, mappedPath, mask, result);

    if (inotifyFileDescriptor == -1)
        inotifyFileDescriptor = fd;

    return result;
}

debug
{
    extern (C) ptrdiff_t read(int fd, void* buf, size_t count)
    {
        static Read func;

        loadSymbol(func, "read");

        immutable result = func(fd, buf, count);

        void *p;

        if (fd == inotifyFileDescriptor)
        {
            log("read(fd: %d, count: %lu), result: %lu\n", fd, count, result);

            for (p = buf; p < buf + result; )
            {
                const event = cast(const(inotify_event)*) p;

                if (event.len > 0)
                    log("name: %s\n", event.name.ptr);
                else
                    log("no length\n");

                p += inotify_event.sizeof + event.len;
            }
        }

        return result;
    }
}

const(char)* mapWatchPath(const char* path)
{
    __gshared static char[FILENAME_MAX] pathBuffer;

    auto sourcePath = path.fromStringz;
    immutable pathMap = config.pathMaps
        .find!(e => sourcePath.startsWith(e.source));

    if (pathMap.isValid)
    {
        auto suffix = sourcePath[pathMap.source.length .. $];
        sourcePath = pathMap.target;
        immutable newLength = sourcePath.length + suffix.length;

        pathBuffer[0 .. sourcePath.length] = sourcePath;
        pathBuffer[sourcePath.length .. newLength] = suffix;
        pathBuffer[newLength] = '\0';

        return cast(const(char)*) pathBuffer[0 .. newLength].ptr;
    }

    else
        return path;
}
