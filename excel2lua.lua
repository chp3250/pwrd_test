local luacom = require('luacom')

local filePath = [[E:/3.csv]]
local excel = luacom.CreateObject("Excel.Application")
assert(luacom.GetType(excel) == "LuaCOM")
local wb = excel.Workbooks:Open(filePath)
assert(luacom.GetType(wb) == "LuaCOM")
local ws = wb.Worksheets(1)
assert(luacom.GetType(ws) == "LuaCOM" )


colum_cnt=ws.UsedRange.Columns.Count
row_cnt=ws.UsedRange.Rows.Count

---@func 取出字段类型及字段名称
local type_dic = {}
local name_dic = {}
for i = 1, colum_cnt do
    -- body
    local type = ws.cells(3, i).Value2
    local name = ws.cells(2, i).Value2
    type_dic[i] = type
    name_dic[i] = name
end

---@func 构造行模板
function buildTempl()
    local  ret = [[
        [%s] = {]]

    local len=#type_dic
    for k, v in pairs(type_dic) do
        if not string.find(v, ":idx") then
            if k == len then
                ret=string.format([[%s%s=%s]], ret, name_dic[k], "%s")
            else
                ret=string.format([[%s%s=%s,]], ret, name_dic[k], "%s")
            end
        end
    end

    ret=string.format("%s},", ret)
    return ret
end

local templ=buildTempl()
io.output("test.lua")
io.write("return {\n")
---@func 2lua
for i = 4, row_cnt do
    local tmp = {}
    for k, v in pairs(type_dic) do
        if string.find(v, ":idx") then
            table.insert(tmp, 1, ws.cells(i,k).Value2)
        elseif v == "string" then
            sv=string.format([["%s"]], ws.cells(i, k).Value2)
            tmp[#tmp+1] = sv
        elseif v == "bool" then
            local bv = ws.cells(i, k).Value2
            if not bv then
                bv = "false"
            else
                bv = "true"
            end
            tmp[#tmp+1] = bv
        else
            tmp[#tmp+1] = ws.cells(i, k).Value2
        end
    end
    print(unpack(tmp))
	result=(string.format(templ, unpack(tmp)))
    io.write(result)
    io.write("\n")
end

io.write("}")
wb:close()
excel:quit()