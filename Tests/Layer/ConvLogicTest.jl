include("../../Computation/Computation.jl")
import Main.Computation
using StaticArrays

"Mutlidimensional kernel operation"
function compute_convND(kernel, inputs, input_steps, kernel_shape, idx, ::Val{N}, ::Type{T}) where {T, N}
    input_index = idx
    kernel_index = 1
    index_vector = MArray{Tuple{N}, T}(undef)
    sum = 0.0
    dim = 1

    for i in 1:length(index_vector)
        index_vector[i] = 1
    end

    "Multidimensional Iteration. Adapted from HyperSphere.Hyperdimensional.Iteration"
    @label iter
    #Check to see if the index is less then the kernel bound
    if index_vector[dim] <= kernel_shape[end - dim + 1]
        if dim != N
            dim += 1
            @goto iter
        else
            for i in 1:kernel_shape[1]
                sum += kernel[kernel_index] * inputs[input_index]
                kernel_index += 1
                index_vector[end] += 1
                input_index += input_steps[end]
            end
        end

    end
    if dim != 1
        #Reset the input_index back to original position
        input_index -= (index_vector[dim] - 1) * input_steps[dim]
        index_vector[dim] = 1
        dim -= 1
        index_vector[dim] += 1
        input_index += input_steps[dim]
        @goto iter
    end

    return sum
end

"Compile Time Converting the linear indexes from the output_mat index to the input_mat index for mapping in kernel"
function convert_index_matrix(input_shape, output_shape)
    output_len = prod(output_shape)
    output_indexes = reshape(collect(1:output_len), output_shape...)
    input_indexes = reshape(collect(1:prod(input_shape)), input_shape...)

    for idx in CartesianIndices(output_indexes)
        output_indexes[idx] = input_indexes[idx]
    end

    return output_indexes
end

"Compile time experimental determination of the summation deltas between dimensions"
function calculate_input_steps(device, output_shape, input_index_mat, input_type, stride)
    steps = Array{input_type}(undef, length(output_shape))
    first_input_entry_index = fill(1, length(output_shape))

    for dim in 1:length(output_shape)
        init = input_index_mat[first_input_entry_index...]
        first_input_entry_index[dim] = stride + 1
        after = input_index_mat[first_input_entry_index...]
        first_input_entry_index[dim] = 1
        steps[dim] = after - init                              #Calculate the step change
    end

    return Computation.alloc(device, reverse(steps))
end

function test_device_conv_logic(device, input_matrix, kernel_matrix)
#START PRECOMPILE CODE
    stride = 1
    input_shape = size(input_matrix)
    kernel_shape = size(kernel_matrix)
    output_shape = input_shape .- kernel_shape .+ 1
    output_matrix = Computation.alloc(device, Int, output_shape...)

    input_type = Computation.get_min_int(prod(input_shape))
    kernel_type = Computation.get_min_int(prod(kernel_shape))

    #Flatten matrixes for far faster operation
    flat_outputs = reshape(output_matrix, :)
    flat_inputs = reshape(input_matrix, :)
    flat_kernel = reshape(kernel_matrix, :)

    #Determine the mathmatics to perform cartesian operations upon the linear indexes at compile time
    converted_indexes = convert_index_matrix(input_shape, output_shape)
    input_steps = calculate_input_steps(device, output_shape, converted_indexes, input_type, stride)
    converted_indexes = Computation.alloc(device, reshape(input_type.(converted_indexes), length(flat_outputs)))     #Flatten the indexes
    

    #Create Singleton arguments
    flat_kernel = Ref(flat_kernel)
    flat_inputs = Ref(flat_inputs)
    input_steps = Ref(input_steps)
    dim_size = Val(length(kernel_shape))
    kernel_shape = Ref(Computation.alloc(device, kernel_type.(kernel_shape)))
#END PRECOMPILE CODE


    @time broadcast!(compute_convND, flat_outputs, flat_kernel, flat_inputs, input_steps, kernel_shape, converted_indexes, dim_size, input_type)
    @time broadcast!(compute_convND, flat_outputs, flat_kernel, flat_inputs, input_steps, kernel_shape, converted_indexes, dim_size, input_type)

    return Array(output_matrix)
end

function test()
    println("Starting Device Conv Layer....")

    input_matrix = [[3,2,4,2,7,6] [8,0,2,1,7,8] [1,5,4,6,5,0] [5,4,1,7,5,6] [5,0,2,7,6,8] [1,1,1,1,1,1]]
    kernel_matrix = [[1,1,1] [0,0,0] [-1,-1,-1]]
    true_array = stride_conv_2D(input_matrix, kernel_matrix)
    #input_matrix = reshape(collect(1:125), 5, 5, 5)
    #kernel_matrix = reshape(collect(1:27), 3, 3, 3)
    #true_array = stride_conv_3D(input_matrix, kernel_matrix)

    for device in Computation.get_devices()
        println("\tChecking $device")
        test = test_device_conv_logic(device, Computation.alloc(device, input_matrix), Computation.alloc(device, kernel_matrix))
        @assert test == true_array "Failed $device Dense Layer Test"
        println("\tSuccesfully Completed $device")
    end
    println("Successfully Compeleted Device Conv Layer Test!")
end

function stride_conv_2D(input, filter)
    input_r, input_c = size(input)
    filter_r, filter_c = size(filter)

    result = zeros(Int, (input_r-filter_r) + 1, (input_c-filter_c) + 1)
    result_r, result_c = size(result)

    ir = 1 
    ic = 1
    for i in 1:result_r
        for j in 1:result_c
            for k in 1:filter_r 
                for l in 1:filter_c 
                 #   (i == j && j == 1) && println(input[ic+l-1, ir+k-1])
                    result[i,j] += input[ir+k-1,ic+l-1]*filter[k,l]
                end
            end
            ic += 1
        end
        ir += 1
        ic = 1 # Return back to 1 after finish looping over column
    end

    return result
end

function stride_conv_3D(input, filter)
    input_d, input_r, input_c = size(input)
    filter_d, filter_r, filter_c = size(filter)

    result = zeros(Int, (input_d-filter_d) + 1, (input_r-filter_r) + 1, (input_c-filter_c) + 1)
    result_r, result_c, result_d = size(result)

    ir = 1 
    ic = 1
    id = 1
    for d in 1:result_d
        for i in 1:result_r
            for j in 1:result_c
                for k in 1:filter_r 
                    for l in 1:filter_c 
                        for q in 1:filter_d
                            result[d,i,j] += input[id+q-1, ir+k-1,ic+l-1]*filter[q,k,l]
                        end
                    end
                end
                ic += 1
            end
            ir += 1 
            ic = 1 # Return back to 1 after finish looping over column
        end
        id += 1
        ir = 1
    end
    return result
end

test()