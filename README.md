# StatsdClient.jl


## Quickstart

```julia
julia> Pkg.add("StatsdClient")
julia> using StatsdClient
```

### Configure the Statsd server

The library defaults to Statsd server at 127.0.0.1:8125.

Ofcourse, you can specify a server ip address and port as well.

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
server = StatsdClient.Statsd("0.0.0.0",8125)
Statsd Server: 0.0.0.0 Port: 8125
StatsdClient.increment(server,"example.increment")
StatsdClient.decrement(server,"example.decrement")
StatsdClient.count(server,"example.count",8)
StatsdClient.timing(server,"example.timing",1)
StatsdClient.gauge(server,"example.gauge",123)
StatsdClient.set(server,"example.set","7623")
```
