local hello = "world"

local var = {a = 1, 2}

function love.load() var = 12 end

local v = (121)

local function bar(a) return not a == a end

function love.update(dt, ...) var = var + dt end

local foo = x(function(a, b) return 1 end)

foo:bar(1)

foo.bar(12)

local x = foo.bar.baz

function a(a) return 1 end

do print("yes") end

while true do
    print("hello")
    print("world")
    print("!")
end

for i = 1, 10, 2 do print(i) end

for i, v in ipairs(table_name) do print(i, v) end

if true then
    print("true")
elseif false then
    print("false")
else
    print("other")
end

