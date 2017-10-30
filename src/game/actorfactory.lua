

local classes = {}

function af_register(atype, cons)
    classes[atype] = cons
end

function af_spawn(atype)
    return classes[atype]()
end

factory = {
    spawn = af_spawn,
    register = af_register
}

return factory
