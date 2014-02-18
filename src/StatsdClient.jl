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
Statsd(ip::String,port=8125) = Statsd(parseip(ip),port)

import Base.show
show(io::IO,client::Statsd) = print(io,string("Statsd Server: ",
                                              client.server_address,
                                              " Port: ",
                                              client.server_port))

function _make_send(ip,port)
    sock = UdpSocket()
    Base.bind(sock,ip,0)
    Base.setopt(sock,enable_broadcast=1)
    (data)->send(sock,ip,port,data)
end

increment(cl::Statsd,metric) = count(cl,metric,1)

decrement(cl::Statsd,metric) = count(cl,metric,-1)

count(cl::Statsd,metric,value) = cl.send_msg(string(metric,":",value,"|c"))

timing(cl::Statsd,metric,value) = cl.send_msg(string(metric,":",value,"|ms"))

gauge(cl::Statsd,metric,value) = cl.send_msg(string(metric,":",value,"|g"))

set(cl::Statsd,metric,value) = cl.send_msg(string(metric,":",value,"|s"))

# versions of the above that accept multiple metrics at once
for f in [:count, :timing, :gauge, :set]
    @eval begin
        function $(f)(cl::Statsd, metrics::Union(AbstractArray, Tuple), value)
            for m in metrics
                $(f)(cl, m, value)
            end
        end
    end
end

end
