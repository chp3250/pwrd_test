---@func 获取时间戳
function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

---@func 多参数格式化通用模板
---@param f  write 函数
function templateFmt(f, ...)
    for _, v in ipairs({...}) do
        f(v)
        f("\t")
    end
    f("\n")
end

---@func 打印重写实现
function print(...)
    local out_filename
    local pre_string
    local arg = {...}
    if arg[1] == "err" or arg[1] == "sys" or arg[1] == "debug" then
        out_filename = os.date(string.format("%s_%s", arg[1],"%Y_%m_%d.log"), os.time())
        pre_string = tostring(timestamp())
    end

    if out_filename then
        templateFmt(io.write, pre_string, ...)
        local fd, ret=io.open(out_filename, "a+")
        if fd then
            templateFmt(function(a) fd:write(a) end, pre_string, ...)
            fd:close()
        end

        ---删除30天前日志文件
        assert(io.popen('forfiles /m *.log /d -30 /c "cmd /c del /f @path" 2>nul'))
    else
        templateFmt(io.write, ...)
    end
end

------- 测试部分
print(123)
print("err", "call stack ...", "param 3")
print("sys", "call stack ...")