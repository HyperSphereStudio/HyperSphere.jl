include("../../Computation/Computation.jl")
using Main.Computation

activation_func(x) = -x
sum_el(temp, idx, input_shape, activ) = activ(sum(view(temp, idx, 1:input_shape)))

function test_device_dense_logic(device)
    #Length of the array of data that the dense layer takes in
    input_shape = (5)
    #Output Size
    size = 10
    
    #Creates an array 1->size to be used in parallelized operations. Will be precalculated beforehand for actual layer
    indexes = alloc(device, collect(1:size))
    
    #Creates a matrix size:input_length that holds all the constants 
    constants = alloc(device, fill(2, size, input_shape[1]))
    
    #Create an intermediate matrix that holds the output of the multiplication step
    temp = alloc(device, Int, size, input_shape[1])
    
    #The output array
    outs = alloc(device, Int, size)
    
    #The input array with dummy values
    ins = alloc(device, collect(1:size))

    #Select every row of constants and multiplty every element the corresponding element in inputs (IE: Weight the input).
    #Store the results in temp
    broadcast!(*, temp, constants, ins)
    
    #Take in the temp array, get the output row from the step above then sum the row and calculate activation value on the sum
    #Store the results in outs array
    broadcast!(sum_el, outs, Ref(temp), indexes, input_shape[1], activation_func)

    return Array(outs)
end

function test()
    println("Starting Device Dense Layer....")
    true_array = [-10, -20, -30, -40, -50, -60, -70, -80, -90, -100]
    for device in get_devices()
        println("\tChecking $device")
        @assert test_device_dense_logic(device) == true_array "Failed $device Dense Layer Test"
        println("\tSuccesfully Completed $device")
    end
    println("Successfully Compeleted Device Dense Layer Test!")
end

test()