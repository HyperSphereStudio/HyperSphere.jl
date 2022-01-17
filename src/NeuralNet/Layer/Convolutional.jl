#Written By Johnathan Bizzano
using ...HSMath

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
function calculate_input_steps(output_shape, input_index_mat, input_type, stride)
    steps = Array{input_type}(undef, length(output_shape))
    first_input_entry_index = fill(1, length(output_shape))

    for dim in 1:length(output_shape)
        init = input_index_mat[first_input_entry_index...]
        first_input_entry_index[dim] = stride + 1
        after = input_index_mat[first_input_entry_index...]
        first_input_entry_index[dim] = 1
        steps[dim] = after - init                              #Calculate the step change
    end

    return reverse(steps)
end

"Mutlidimensional kernel operation"
function generate_compute_kernelND(T, N, pre_kernel, kernel, post_kernel)
    return :(
        function(input_array, kernel_array, input_steps, kernel_shape, idx, activation)
            input_index = idx
            kernel_index = 1
            index_vector = MArray{Tuple{$N}, $T}(undef)
            dim = 1

            for i in 1:length(index_vector)
                index_vector[i] = 1
            end

            $pre_kernel

            "Multidimensional Iteration. Adapted from HyperSphere.Hyperdimensional.Iteration"
            @label iter
            #Check to see if the index is less then the kernel bound
            if index_vector[dim] <= kernel_shape[end - dim + 1]
                if dim != N
                    dim += 1
                    @goto iter
                else
                    for i in 1:kernel_shape[1]
                        $kernel
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

            $post_kernel
        end)
end

#pre_kernel runs before every kernel op. Void input and no args
#kernel runs in every kernel op. Takes in kernel_index and input_index
#post_kernel runs at the completion of every kernel op. Must return input_type value
"A convolutional neural network (CNN, or ConvNet) is a class of artificial neural network, most commonly applied to analyze visual imagery - Wikipedia"
function Kernel(filter_count, sig, initializer, kernel_shape, stride, constant_shape, activation, pre_kernel, kernel, post_kernel)
    return LayerGenerator(
        function (pb, sett, input_shape)
            device = sett.device
            output_shape .= input_shape .- kernel_shape .+ 1
            
            input_type = get_min_int(prod(input_shape))
            kernel_type = get_min_int(prod(kernel_shape))

            #Determine the mathmatics to perform cartesian operations upon the linear indexes at compile time
            converted_indexes = convert_index_matrix(input_shape, output_shape)
            input_steps = calculate_input_steps(output_shape, converted_indexes, input_type, stride)

            compute_kernelND = eval(generate_compute_kernelND(input_type, length(kernal_shape), pre_kernel, kernel, post_kernel))
            ref_kernel_shape = prealloc_readonly!(pb, kernel_type.(kernel_shape))
            input_steps = prealloc_readonly!(pb, input_steps)
            converted_indexes = prealloc_readonly!(pb, reshape(input_type.(converted_indexes), length(flat_outputs)))     #Flatten the indexes
            
            LayerDesign(sig, input_shape, (filter_count > 1) ? (output_shape..., filter_count) : output_shape, constant_shape, initializer, 
                    function (input_matrixes, output_matrixes, kernel_matrixes)
                        flat_inputs = Ref(reshape(input_matrix, :))
                        input_steps = Ref(input_steps())
                        converted_indexes = converted_indexes()

                        output_matrix_collection = []
                        kernel_matrix_collection = []
                        
                        for i in 1:filter_count
                            #Flatten matrixes for far faster operation
                            push!(output_matrix_collection, Ref(reshape(view(output_matrixes, output_shape..., i), :)))
                            push!(kernel_matrix_collection, Ref(reshape(view(kernel_matrixes, kernel_shape..., i), :)))
                        end
                        
                        return function ()
                                    for i in eachindex(output_matrix_collection)
                                        broadcast!(compute_kernelND, output_matrix_collection[i], flat_inputs, kernel_matrix_collection[i], input_steps, ref_kernel_shape, converted_indexes, activation)
                                    end
                               end
                    end)
            
        end)
end


function Convolutional(filter_count, initializer; kernel_shape, stride=1, activation=Activation.None())
    return Kernel(filter_count, Sig(:ConvolutionalLayer), initializer, kernel_shape, stride, kernel_shape, activation,
                :(sum = 0.0),
                :(sum += kernel_array[kernel_index] * input_array[input_index]),
                :(activation(sum)))
end

function MaxPooling(; kernel_shape, stride=1, activation=Activation.None())
    return Kernel(1, Sig(:MaxPoolingLayer), initializer, kernel_shape, stride, (0), activation,
                :(maxVal = -Inf),
                :(maxVal += max(maxVal, input_array[input_index])),
                :(activation(maxVal)))
end

export ConvolutionalLayer, MaxPoolingLayer
ConvolutionalLayer(filter_count, initializer; kernel_shape, stride=1, activation=Activation.None()) = Convolutional(filter_count, initializer; kernel_shape=kernel_shape, stride=stride, activation=activation)
MaxPoolingLayer(; kernel_shape, stride=1, activation=Activation.None()) = MaxPooling(; kernel_shape=kernel_shape, stride=stride, activation=activation)







