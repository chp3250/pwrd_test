local socket = require("socketextra")
local string = require("string")
local base = _G

module("httpclient")


local GetTemplate=[[GET %s HTTP/1.1
Host: %s
User-Agent: %s
Connection: close

]]

local PostTemplate=[[POST %s HTTP/1.1
Host: %s
User-Agent: %s
Connection: close

%s
]]

local httpclient = {}
local User_Agent = socket._VERSION

--- @param host 输入地址，可包含端口
function httpclient.parsehost(host)
    local parsed = {}
    parsed.host = string.gsub(host, ":([0-9]*)$",
        function(p) parsed.port = p; return "" end)

    if not parsed.port then parsed.port = 80 end
    return parsed
end

--- 构造报文
--- @param ... 相关参数
function httpclient.packmsg(method, ...)
    if "Get" == method then
        return string.format(GetTemplate, ...)
    else
        return string.format(PostTemplate, ...)
    end
end

--- post data 预处理
--- @param data {key=value ...}
function httpclient.prepostdata(data)
    if not data then return end
    local ret
    for k, v in base.pairs(data) do
        if ret then
            ret = string.format("%s&%s=%s", ret, k , v)
        else
            ret = string.format("%s=%s", k , v)
        end
    end
    return ret
end

-- 连接上的回调函数
function httpclient.onconnected(rq)
    return function(fd)
        base.print("connect ok.")
        rq.fd = fd
    end
end

-- 连接失败回调
function httpclient.onclosed(fd, reason)
    base.print("connect failed reason:", reason)
    --return fd, reason
end

-- reponse
function httpclient.rescb(rq)
    return function(fd, data)
        rq.cb(rq, data)
        fd:close()
    end
end

-- @param host 服务器地址, 可包含端口
-- @param path 资源路径
function httpclient.get(host, path)
    local rq_get = httpclient.parsehost(host)
    rq_get.path = path
    rq_get.method = "Get"

    socket.connect(rq_get.host, rq_get.port, httpclient.onconnected(rq_get), httpclient.onclosed)
    return rq_get
end

-- @param host 服务器地址, 可包含端口
-- @param path 资源路径
-- @param data 数据
function httpclient.post(host, path, data)
    local rq_post = httpclient.parsehost(host)
    rq_post.path = path
    rq_post.data = httpclient.prepostdata(data)

    socket.connect(rq_post.host, rq_post.port, httpclient.onconnected(rq_post), httpclient.onclosed)
    return rq_post
end

-- 正式请求
-- @param request 请求数据
function httpclient.request(request)
    if not request.fd then
        base.print("not connect.")
        return
    end

    local msg = httpclient.packmsg(request.method, request.path, request.host, User_Agent, request.data)
    socket.write(request.fd, msg)

    socket.read(request.fd, 1024, httpclient.rescb(request))
end

return httpclient