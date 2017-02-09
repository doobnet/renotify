module renotify.path_map;

struct PathMap
{
    immutable string source;
    immutable string target;

    bool isValid() const
    {
        return source.length > 0 && target.length > 0;
    }
}
