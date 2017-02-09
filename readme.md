# Renotify

Renotify is a tool/library to redirect applications which uses
[`inotify`](https://en.wikipedia.org/wiki/Inotify). If an
application is using `inotify` to listen for filesystem events on a specific
path, Renotify can be used to redirect that path to different path.

Renotify only works on Linux because it specifically targets the `inotify` Linux
kernel subsystem.

## Building

### Requirements

* D compiler [https://dlang.org/download.html](https://dlang.org/download.html).
  DMD 2.073.0 has been tested

### Building

1. Create a new file called `config.d` in `source` directory. This file will
configure which paths should be redirect and to which file to write log
messages to. The `config.d` file should have content similar to:

    ```d
    module config;

    import renotify.path_map;

    // This is the path to the renotify log file.
    // It will be used for debug builds. Optional
    enum logPath = "/path/to/renotify.log";

    // This is an array that maps the source paths to the paths which Renotify
    // should redirect to, the target paths. Required
    __gshared immutable pathMaps = [
        // source path            the target path
        PathMap("/home/joe/foo",  "/home/joe/bar"),
        PathMap("/home/joe/foo2", "/home/joe/bar2"),
    ];
    ```

2. Execute the [`build.sh`](https://github.com/doobnet/renotify/blob/master/build.sh)
shell script in the root directory of the project. This will produce a file
called `librenotify.so` in the root of the project directory.

The reason why Dub is not used to build the library is that the library needs to
be built as a shared library without linking with either Phobos or druntime.
Unfortunately this is not supported by Dub.

## Running the Tests

### Requirements

* Dub [https://code.dlang.org/download](http://code.dlang.org/download)

### Running the Tests

To run the tests invoke `dub test` from the root directory of the project.

## Usage

To use Renotify, start the application that should have its `inotify` listening
redirected with the `LD_PRELOAD` environment variable with the path to
`librenotify.so` as the value. For example:

```
LD_PRELOAD=/usr/local/librenotify.so inotifywait -m --format "%e %f" /home/joe/foo
```

Assuming the configuration used in the [first build step](https://github.com/doobnet/renotify#building-1),
the above command will listen for filesystem events in `/home/joe/bar` instead
of the specified `/home/joe/foo`

## How Renotify Works

Renotify is built as a shared library. This library contains an implementation
of the `inotify` function/system call [`inotify_add_watch`](https://linux.die.net/man/2/inotify_add_watch),
with the signature:

```d
extern (C) int inotify_add_watch(int fd, const char* pathname, uint mask)
```

When an application is stared with the
`LD_PRELOAD=/usr/local/librenotify.so` environment variable the
`inotify_add_watch` function implemented in `librenotify.so` will take
precedence of the function implemented by the operating system.

When the application calls the `inotify_add_watch` function, the implementation
in `librenotify.so` will receive the call. The implementation will look for the
passed in `pathname` in the configured `pathMaps`. If the given `pathname`
starts with any of the paths in `pathMaps` it will replace the given `pathname`
with the target found in `pathMaps`.

It will then call the original implementation of `inotify_add_watch` with the
new `pathname` using [`dlsym`](https://linux.die.net/man/3/dlsym) with the
`RTLD_NEXT` handle.
