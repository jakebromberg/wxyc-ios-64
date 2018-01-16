/// The `TimeBasedCache` is a mechanism for caching values that expire after a prescribed duration.
/// The motivation stems from a need to minimize network fetches for resources. More specifically, Last.FM degrades
/// image resolutions if a client issues more than 5 requests within a 5 minute interval.
/// Within a single process, it's sufficient to rate limit these requests based on a timer. However, this model breaks
/// down when considering the full range of contexts that requests get issued: in addition to the primary app, we have
/// homescreen "today" widgets and Apple Watch apps and "complications". All of these contexts share a common "app group
/// container", and can schedule requests based on a timestamp that accompanies any writes to the cache.
final class TimeBasedCache {
    
}
