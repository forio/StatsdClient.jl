module StatsdClient
# A simple statsd client written in Julia
# Usage:
# > using StatsdClient
# > server = StatsdClient.Statsd()
# Statsd Server: 127.0.0.1 Port: 8125
# You can also specify the server address and port number
# (port defaults to 8125)
# > sdc = StatsdClient.Statsd("0.0.0.0",8125)
# Statsd Server: 0.0.0.0 Port: 8125
# > StatsdClient.increment(sdc,"test.me")
# Please refer to the readme for more examples.
# Note: Requires Julia 0.3 with commit sha 6585e3de1b or later.

export increment, decrement, count, gauge, timing

type Statsd
    server_address::IPv4
    server_port::Int
    send_msg::Function
    Statsd(ipv4::IPv4,port) = new(ipv4,port,_make_send(ipv4,port))
end
Statsd() = Statsd(IPv4(127,0,0,1),8125)
Statsd(ip::String,port=8125) = Statsd(getaddrinfo(ip),port)

import Base.show
show(io::IO,client::Statsd) = print(io,string("Statsd Server: ",
                                              client.server_address,
                                              " Port: ",
                                              client.server_port))

function _make_send(ip,port)
    sock = UdpSocket()
    Base.bind(sock,ip,0)
    Base.setopt(sock,enable_broadcast=1)
    function _send(data,sample_rate::Union(Number,Nothing)=nothing)
        if is(sample_rate,nothing)
            send(sock,ip,port,data)
        elseif (0 <= sample_rate <= 1) &&
               rand() < sample_rate
            send(sock,ip,port,string(data,"|@",sample_rate))
        end
    end
end

increment(cl::Statsd,metric,sample_rate=nothing) = count(cl,metric,1,sample_rate)

decrement(cl::Statsd,metric,sample_rate=nothing) = count(cl,metric,-1,sample_rate)

count(cl::Statsd,metric,value,
      sample_rate=nothing) = cl.send_msg(string(metric,":",value,"|c"),sample_rate)

timing(cl::Statsd,metric,value,
       sample_rate=nothing) = cl.send_msg(string(metric,":",value,"|ms"),sample_rate)

gauge(cl::Statsd,metric,value,
      sample_rate=nothing) = cl.send_msg(string(metric,":",value,"|g"),sample_rate)

set(cl::Statsd,metric,value,
    sample_rate=nothing) = cl.send_msg(string(metric,":",value,"|s"),sample_rate)

# versions of the above that accept multiple metrics at once
for f in [:count, :timing, :gauge, :set]
    @eval begin
        function $(f)(cl::Statsd, metrics::Union(AbstractArray, Tuple), value,
                      sample_rate=nothing)
            for m in metrics
                $(f)(cl, m, value, sample_rate)
            end
        end
    end
end

end
