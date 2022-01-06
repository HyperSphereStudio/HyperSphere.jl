#Written By Johnathan Bizzano
include("../src/Computation/Computation.jl")
using Main.Computation


f(a, b) = 3 * (a + b)

function test_kernels(device)
    a = alloc(device, collect(1:10))
    b = alloc(device, collect(2:11))
    broadcast!(f, a, a, b)
    return Array(a)
end

function test_device_kernels()
    println("Starting Device Kernel Operation Test....")
    true_array = [f(i, i + 1) for i in 1:10]
    for device in get_devices()
        println("\tChecking $device")
        @assert test_kernels(device) == true_array "Failed $device Kernel Operation Test"
        println("\tSuccesfully Completed $device")
    end
    println("Successfully Compeleted Device Kernel Operation Tes!")
end

test_device_kernels()
