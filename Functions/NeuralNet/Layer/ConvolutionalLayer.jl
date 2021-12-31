"Written By Johnathan Bizzano"
export ConvolutionalLayer2D, MaxPoolingLayer2D

using ...HSMath
using ...HyperDimensional

@Fun(Kernal2DFunc{StorageType, InputType, OutputType}, result::OutputType, row::Int, col::Int, constant_pointer::APtr{StorageType}, inputs::APtr{InputType}, outputs::APtr{OutputType})
@Fun(KernalWrapper2D, layer::Kernal2DFunc, StorageType::Type, InputType::Type, OutputType::Type, inputitrp::MDArrayInterpreter, kernelitrp::MDArrayInterpreter)


"A convolutional neural network (CNN, or ConvNet) is a class of artificial neural network, most commonly applied to analyze visual imagery - Wikipedia"


function Kernal2D(const_initializer, const_count, inputdims, kernaldims, outputdims, stride, kernalWrapper::KernalWrapper2D)
    #Right Up Bias meaning it will be more right and up offset then down and left when odd kernal size

    doubleRowOffset = stride * (outputdims[1] - 1) + kernaldims[1] - inputdims[1]
    doubleColOffset = stride * (outputdims[2] - 1) + kernaldims[2] - inputdims[2]

    colStart = 1 - Int(floor(doubleColOffset / 2))
    rowStart = 1 - Int(floor(doubleRowOffset / 2))
    colEnd = outputdims[1] - colStart - 1
    rowEnd = outputdims[2] - rowStart - 1

    input2itrp = MDArrayInterpreter(inputdims)
    output2itrp = MDArrayInterpreter(outputdims)
    kernal2itrp = MDArrayInterpreter(kernaldims)

    return Wrapper(
        function (ST, IT, OT)
            kernalFunction = kernalWrapper(ST, IT, OT, input2itrp, kernal2itrp)
            #In order for conv layer to be same size, kernal must have offset
            Layer{ST, IT, OT, length(input2itrp), length(output2itrp)}(const_count, const_initializer, 
                Func{ST, IT, OT}(
                    function (constants, inputs, outputs)
                        #Matrix Iteration
                        output_row = 1
                        for row in rowStart:stride:rowEnd
                            output_col = 1
                            for col in colStart:stride:colEnd
                                outputs[output2itrp, output_row, output_col] = kernalFunction(row, col, constants, inputs, outputs)
                                output_col += 1
                            end
                            output_row += 1
                        end
                    end))
        end)
end


function ConvolutionalLayer2D(const_initializer; inputdims, kernaldims, outputdims = inputdims, stride = 1)
    return Kernal2D(const_initializer, ∏(kernaldims), inputdims, kernaldims, outputdims, stride,  
                KernalWrapper2D((ST, IT, OT, initrp, kitrp) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        sum::IT = 0

                        #2D kernal Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow::Int = row + krow - 1
                                realCol::Int = col + kcol - 1
                                checkbounds(initrp, realRow, realCol) || continue
                                value = inputs[initrp, realRow, realCol]
                                ####

                                #Dot Product
                                sum += constants[kitrp, krow, kcol] * value
                            end
                        end
                        return sum
                    end)))
end

function MaxPoolingLayer2D(; inputdims, kernaldims, outputdims = inputdims, stride = 1)
    return Kernal2D(nothing, 0, inputdims, kernaldims, outputdims, stride, 
                KernalWrapper2D((ST, IT, OT, initrp, kitrp) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        maxval::IT = -Inf

                        #2D kernal Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow::Int = row + krow - 1
                                realCol::Int = col + kcol - 1
                                checkbounds(initrp, realRow, realCol) || continue
                                value = inputs[initrp, realRow, realCol]
                                ####

                                maxval = max(maxval, value)
                            end
                        end
                        return maxval
                    end)))
end






