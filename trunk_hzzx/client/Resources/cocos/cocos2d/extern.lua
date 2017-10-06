
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--Create an class.
function class(classname, super)
    local superType = type(super)
    local subClass
    if "function" ~= superType and "table" ~= superType then
        superType = nil
        super = nil
    end
	super = clone(super)
    if "function" == superType or (super and 1 == super.__ctype) then
        -- inherited from native C++ Object
        subClass = {}
        if "table" == superType then
            subClass.__create = super.__create
            subClass.super = super
        else
            subClass.__create = super
            subClass.ctor = function() end
        end
		subClass.__cname = classname
        subClass.__ctype = 1
        subClass.new = function(...)
            local instance = subClass.__create(...)
            instance.class = subClass
            instance:ctor(...)
            return instance
        end
    else
        -- inherited from Lua Object
        if super then
            subClass = {}
            setmetatable(subClass, {__index = super})
            subClass.super = super
        else
            subClass = {ctor = function() end}
        end
		subClass.__cname = classname
        subClass.__ctype = 2 -- lua
        subClass.__index = subClass
        subClass.new = function(...)
            local instance = setmetatable({}, subClass)
            instance.class = subClass
            instance:ctor(...)
            return instance
        end
    end
    return subClass
end

function schedule(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    node:runAction(action)
    return action
end

function performWithDelay(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end
