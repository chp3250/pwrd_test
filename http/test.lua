local httpclient = require("httpclient")

local cb = function(rq, res)
    print("cb", rq.arg1, res)
end

--local rq_get = httpclient.get("127.0.0.1", "/test")
local rq_get = httpclient.get("127.0.0.1", "/")
rq_get.cb = cb
rq_get.arg1 = "111111"

httpclient.request(rq_get)


local rq_post = httpclient.post("127.0.0.1:80", "/err_2020_08_18.log", {username = "wang", passwd = "456", arg = 110})

rq_post.cb = cb
rq_post.arg1 = "222222"
httpclient.request(rq_post)



