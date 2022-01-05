export Device, @setup_devices, alloc, name, arraytype, get_devices, get_device

abstract type Device end

name(device::Device) = ()

arraytype(device::Device) = ()

"Alloc to the memory type"
alloc(device::Device, tup::Tuple) = alloc(device, [i for i in tup])
alloc(device::Device, array::AbstractArray) = ()
alloc(device::Device, T::Type, indxs...) = ()   

include("CPUImpl.jl")
include("CUDAImpl.jl")

const CPUDev = CPUDevice()

devices = Device[CPUDev]

get_devices() = devices


function get_device(device_name::Symbol)
    for i in 1:length(devices)
        (name(devices[i]) == device_name) && return devices[i]
    end
    return nothing
end

macro setup_devices()
    for device in devices
        deviceName = "$(device.name).jl"
        Core.eval(__module__, esc(:(include($deviceName))))
    end
end 

function __init_device__()
    println("========Initializing HyperSphere Deep Learning======")
    (Threads.nthreads() < 8) && println("WARNING: THREADS LESS THEN 8. RECOMMENDED TO BE ATLEAST 8")        
    println("CPU Thread Count:", Threads.nthreads())
    println("GPU Count:", CUDA.functional(false) ? length(CUDA.devices()) : 0)
    if CUDA.functional(false)
        push!(devices, CUDADevice())
    end
    println("Devices Available:$devices")
    println("==============")
end






