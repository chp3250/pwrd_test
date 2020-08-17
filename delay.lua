local socket = require("socket")

local M = {
}

function M:initialize()
    self._delays = {}
end

---@func  每帧执行检查
---@para dt 毫秒
function M:update(dt)
    local list = self._delays -- 需要延后执行的列表
    local len = #list
    for i=1, len do
        local tmp = list[i]
        if tmp.timeout <= socket.gettime()*1000 then
            tmp.cb(unpack(tmp.params))
            list[i] = nil
        end
    end

    local j = 0
    for i=1, len do
        if list[i] ~= nil then
            j = j+1
            list[j] = list[i]
        end
    end
    for i=j+1, len do
        list[i] = nil
    end
end

---@func 创建延时函数, 只执行一次
---@param  duration 毫秒
---@param  f 回调函数
---@param  ... 其他需要回调时透传的参数
function M:settimeout(duration, f, ...)
    local delay = {}
    delay.timeout = socket.gettime()*1000 + duration
    delay.cb = f
    delay.params = {...}
    
    self._delays[#self._delays+1] = delay
end

---@func 测试用回调函数
function f(...)
    for k, v in pairs({...})
    do
        print("-----", k, v)
    end
end

----- 测试部分
M:initialize()
M:settimeout(1000, f, 1,2,3,4)
M:settimeout(5000, f, "a","b","c","d")

while true do
    M:update()
    print("curTime:", socket.gettime()*1000)
    socket.sleep(1)
end
