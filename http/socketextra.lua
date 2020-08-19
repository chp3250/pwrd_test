local socket = require("socket")
local string = require("string")
local math = require("math")
local base = _G

module("socketextra")
local socketextra = {}

socketextra._VERSION = socket._VERSION

-- 监听
-- @param onaccepted 新连接回调函数, 接收参数 fd, address
-- @param onclosed 连接关闭的回调函数, 接收参数 fd， reason
function socketextra.listen(host, port, onaccepted, onclosed)
    local sock, reason = socket.bind(host, port)
    if not sock then
        onclosed(sock, reason)
    else
        onaccepted(sock)
    end
end

-- 连接
-- @param onconnected 连接回调函数, 接收参数 fd
-- @param onclosed 连接关闭的回调函数, 接收参数 fd， reason
function socketextra.connect(host, port, onconnected, onclosed)
    local sock, reason = socket.connect(host, port)
    if not sock then
        onclosed(sock, reason)
    else
        onconnected(sock)
    end
end

-- 设置超时
function socketextra.settimeout(fd, dt)
    fd.settimeout(dt)
end

-- 读指定长度的数据
-- @param length int
-- @param cb 回调函数, 接收参数 fd, data
function socketextra.read(fd, length, cb)
    if length <= 0 then return nil end
    local size = math.min(socket.BLOCKSIZE, length)
    local chunk, err, partial= fd:receive(size)
    cb(fd, chunk or partial)
end

-- 读指定分隔符的数据
-- @param delim string
-- @param cb 回调函数, 接收参数 fd, data
function socketextra.readline(fd, delim, cb)
    local data=""
    repeat
        local chunk, err, partial= fd:receive(1)
        local tmp = chunk or partial
        if tmp then
            data = string.format("%s%s",  data, tmp)
        end
    until tmp and tmp == delim or err
    cb(fd, data)
end

-- 向连接发送消息socket.write(fd, msg)
function socketextra.write(fd, msg)
    --base.print(msg)
    fd:send(msg)
end

return socketextra