

local classes = {}

function af_register(atype, cons)
    classes[atype] = cons
end

function af_spawn(atype, id)
    return classes[atype](id)
end

factory = {
    spawn = af_spawn,
    register = af_register
}

return factory
