export ConvolutionalLayer2D, PoolingLayer2D

using ..Utils

@VFun(Kernal2DFunc{StorageType, InputType, OutputType}, row::Int, col::Int, constant_pointer::APtr{StorageType}, inputs::APtr{InputType}, outputs::APtr{OutputType})
@Fun(KernalWrapper2D, layer::Kernel2DFunc, StorageType::Type, InputType::Type, OutputType::Type)


"A convolutional neural network (CNN, or ConvNet) is a class of artificial neural network, most commonly applied to analyze visual imagery - Wikipedia"


function Kernal2D(const_initializer, const_count, inputdims, kerneldims, outputdims, kernalWrapper::KernelWrapper2D)
    #Right Up Bias meaning it will be more right and up offset then down and left when odd kernel size
    rightOffset = 
    leftOffset = 
    upOffset = 
    downOffset = 

    return Wrapper(
        function (ST, IT, OT)
            kernalFunction = kernalWrapper(ST, IT, OT)
            #In order for conv layer to be same size, kernel must have offset
            Layer{ST, IT, OT, ∏(inputdims), ∏(outputdims)}(const_count, const_initializer, 
                Func{ST, IT, OT}(
                    function (constants, inputs, outputs)
                        #Matrix Iteration
                        for row in (1 - downOffset):(inputdims[1] + upOffset)
                            for col in (1 - rightOffset):(inputdims[2] + leftOffset)
                                kernalFunction(row, col, constants, inputs, outputs)
                            end
                        end
                    end))
        end)


function ConvolutionalLayer2D(const_initializer; inputdims, kerneldims, outputdims = inputdims)
    return Kernel2D(const_initializer, ∏(kerneldims), inputdims, kerneldims, outputdims, 
                KernelWrapper2D((ST, IT, OT) -> Kernel2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        sum::IT = 0

                        #2D Kernel Template
                        for krow in 1:kerneldims[1]
                            for kcol in 1:kerneldims[2]
                                realRow = row + krow - 1
                                realCol = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                sum += constants[kerneldims[1], krow, kcol] * value
                            end
                        end
                        outputs[outdims[1], row, col] = sum
                    end)))
end

function MaxPoolingLayer2D(; inputdims, kernaldims, outputdims = inputdims)
    return Kernal2D(nothing, 0, inputdims, kernaldims, outputdims, 
                KernalWrapper2D((ST, IT, OT) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        maxval::IT = -Inf

                        #2D Kernel Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow = row + krow - 1
                                realCol = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                maxval = max(maxval, value)
                            end
                        end
                        outputs[outdims[1], row, col] = maxval
                    end)))
end

function MinPoolingLayer2D(; inputdims, kernaldims, outputdims = inputdims)
    return Kernal2D(nothing, 0, inputdims, kernaldims, outputdims, 
                KernalWrapper2D((ST, IT, OT) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        minval::IT = Inf

                        #2D Kernel Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow = row + krow - 1
                                realCol = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                minval = min(minval, value)
                            end
                        end
                        outputs[outdims[1], row, col] = minval
                    end)))
end






