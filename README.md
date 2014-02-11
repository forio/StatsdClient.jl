# StatsdClient.jl

A simple Julia implementation of a statsd client.

## Quickstart

```julia
julia> Pkg.add("StatsdClient")
julia> using StatsdClient
```

### Configure the Statsd server

The library defaults to Statsd server at 127.0.0.1:8125.

You can specify a server ip address and port as well.

```julia
server = StatsdClient.Statsd()
Statsd Server: 127.0.0.1 Port: 8125
```

You can leave out the port number, in which case we use the default port of 8125.

```julia
server = StatsdClient.Statsd("0.0.0.0")
Statsd Server: 0.0.0.0 Port: 8125
```

Or you can specify the server ip address and port number.

```julia
server = StatsdClient.Statsd("0.0.0.0",8125)
Statsd Server: 0.0.0.0 Port: 8125
```

### Using StatsdClient

Buckets can be either strings or keywords. 
For more information please refer to [statsd](https://github.com/etsy/statsd "statsd Github")
and [Measure Anything, Measure Everything blog post](http://codeascraft.com/2011/02/15/measure-anything-measure-everything/).


```julia
# configure statsd server
server = StatsdClient.Statsd("0.0.0.0",8125)
Statsd Server: 0.0.0.0 Port: 8125
```
increment/decrement buckets/counter
```julia
# increment example.increment bucket
StatsdClient.increment(server,"example.increment")
# decrement example.decrement
StatsdClient.decrement(server,"example.decrement")
```
Counters are the most basic statsd type.
```julia
# counter : adds 8 to example.count
StatsdClient.count(server,"example.count",8)
```
Timers are meant to track the duration of some event. The statsd server operates only in milliseconds. So everything should be converted accordingly.
```julia
# timing : example.timing took 224ms to complete 
StatsdClient.timing(server,"example.timing",224)
```
Gauges are a constant data type and they don't change unless you specifically change them (by adding a +/- sign to the value). 
```julia
# gauges : record example.gauge as 123 
# adding a sign to the gauge value will change the value rather than set it.
StatsdClient.gauge(server,"example.gauge",123)
```
Sets count the unique occurrences of events. For example, you can use it to count the number of unique visitors to your site by specifying the visitor's ip address as the value.
```julia
# sets : count unique occurrence of events
StatsdClient.set(server,"example.set","7623")
```
