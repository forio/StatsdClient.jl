using Base.Test

require("../src/StatsdClient.jl")
using StatsdClient

# server socket
function setup_statsd()
    svr = UdpSocket()
    bind(svr,ip"127.0.0.1",2376)
    # configure client with server address
    server = StatsdClient.Statsd("127.0.0.1",2376)
    (svr, server)
end

c = Condition()
function test_statsd(svr,val)
    @async begin
        arg = bytestring(recv(svr))
        println(arg,":",val)
        @test arg == val
        notify(c)
    end
end

function test_increment()
    svr, server = setup_statsd()
    test_statsd(svr,"test.increment:1|c")
    StatsdClient.increment(server,"test.increment")
    wait(c)
    close(svr)
    true
end

function test_decrement()
    svr, server = setup_statsd()
    test_statsd(svr,"test.decrement:-1|c")
    StatsdClient.decrement(server,"test.decrement")
    wait(c)
    close(svr)
    true
end

function test_count()
    svr, server = setup_statsd()
    test_statsd(svr,"test.count:412|c")
    StatsdClient.count(server,"test.count",412)
    wait(c)
    close(svr)
    true
end

function test_timing()
    svr, server = setup_statsd()
    test_statsd(svr,"test.timing:38|ms")
    StatsdClient.timing(server,"test.timing",38)
    wait(c)
    close(svr)
    true
end

function test_gauge()
    svr, server = setup_statsd()
    test_statsd(svr,"test.gauge:123|g")
    StatsdClient.gauge(server,"test.gauge",123)
    wait(c)
    close(svr)
    true
end

function test_set()
    svr, server = setup_statsd()
    test_statsd(svr,"test.set:7623|s")
    StatsdClient.set(server,"test.set","7623")
    wait(c)
    close(svr)
    true
end

function test_sample_rate()
    svr, server = setup_statsd()
    test_statsd(svr,"test.sample_rate:3|c|@1.0")
    StatsdClient.count(server,"test.sample_rate",3,1.0)
    wait(c)
    close(svr)
    true
end

@test test_increment()
@test test_decrement()
@test test_count()
@test test_timing()
@test test_gauge()
@test test_set()
@test test_sample_rate()
