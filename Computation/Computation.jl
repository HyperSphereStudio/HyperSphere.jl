module Computation

    export get_min_int

    include("Devices/Device.jl")
    include("DesignerFunctionWrappers.jl")

    __init__() = __init_device__()

    function get_min_int(size)
        (size <= typemax(Int8)) && return Int8
        (size <= typemax(UInt8)) && return UInt8
        (size <= typemax(Int16)) && return Int16
        (size <= typemax(UInt16)) && return UInt16
        (size <= typemax(Int32)) && return Int32
        (size <= typemax(UInt32)) && return UInt32
        (size <= typemax(Int)) && return Int
        return UInt64
    end
end