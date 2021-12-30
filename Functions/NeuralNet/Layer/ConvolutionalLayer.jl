export ConvolutionalLayer2D, PoolingLayer2D

using ...HSMath

@VFun(Kernal2DFunc{StorageType, InputType, OutputType}, row::Int, col::Int, constant_pointer::APtr{StorageType}, inputs::APtr{InputType}, outputs::APtr{OutputType})
@Fun(KernalWrapper2D, layer::Kernal2DFunc, StorageType::Type, InputType::Type, OutputType::Type)


"A convolutional neural network (CNN, or ConvNet) is a class of artificial neural network, most commonly applied to analyze visual imagery - Wikipedia"


function Kernal2D(const_initializer, const_count, inputdims, kernaldims, outputdims, stride, kernalWrapper::KernalWrapper2D)
    #Right Up Bias meaning it will be more right and up offset then down and left when odd kernal size

    doubleHorizontalPad = (stride * (outputdims[2] - 1) - inputdims[2] + kernaldims[2])
    doubleVerticalPad = (stride * (outputdims[1] - 1) - inputdims[1] + kernaldims[1])

    rightOffset = Int((doubleHorizontalPad % 2 == 0 ? doubleHorizontalPad : (doubleHorizontalPad + 1)) / 2)   
    leftOffset = Int((doubleHorizontalPad % 2 == 0 ? doubleHorizontalPad : (doubleHorizontalPad - 1)) / 2)       
    upOffset = Int((doubleVerticalPad % 2 == 0 ? doubleVerticalPad : (doubleVerticalPad + 1)) / 2)   
    downOffset = Int((doubleVerticalPad % 2 == 0 ? doubleVerticalPad : (doubleVerticalPad - 1)) / 2)   

    return Wrapper(
        function (ST, IT, OT)
            kernalFunction = kernalWrapper(ST, IT, OT)
            #In order for conv layer to be same size, kernal must have offset
            Layer{ST, IT, OT, ∏(inputdims), ∏(outputdims)}(const_count, const_initializer, 
                Func{ST, IT, OT}(
                    function (constants, inputs, outputs)
                        #Matrix Iteration
                        for row in (1 - downOffset):(inputdims[1] + upOffset)
                            for col in (1 - leftOffset):(inputdims[2] + rightOffset)
                                kernalFunction(row, col, constants, inputs, outputs)
                            end
                        end
                    end))
        end)
end


function ConvolutionalLayer2D(const_initializer; inputdims, kernaldims, outputdims = inputdims, stride = 1)
    return Kernal2D(const_initializer, ∏(kernaldims), inputdims, kernaldims, outputdims, stride,  
                KernalWrapper2D((ST, IT, OT) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        sum::IT = 0

                        #2D kernal Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow::Int = row + krow - 1
                                realCol::Int = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                #Dot Product
                                sum += constants[kernaldims[1], krow, kcol] * value
                            end
                        end
                        outputs[outputdims[1], row, col] = sum
                    end)))
end

function MaxPoolingLayer2D(; inputdims, kernaldims, outputdims = inputdims, stride = 1)
    return Kernal2D(nothing, 0, inputdims, kernaldims, outputdims, stride, 
                KernalWrapper2D((ST, IT, OT) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        maxval::IT = -Inf

                        #2D kernal Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow::Int = row + krow - 1
                                realCol::Int = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                maxval = max(maxval, value)
                            end
                        end
                        outputs[outputdims[1], row, col] = maxval
                    end)))
end

function MinPoolingLayer2D(; inputdims, kernaldims, outputdims = inputdims, stride = 1)
    return Kernal2D(nothing, 0, inputdims, kernaldims, outputdims, stride,  
                KernalWrapper2D((ST, IT, OT) -> Kernal2DFunc{ST, IT, OT}(
                    function(row, col, constants, inputs, outputs)
                        minval::IT = Inf

                        #2D kernal Template
                        for krow in 1:kernaldims[1]
                            for kcol in 1:kernaldims[2]
                                realRow::Int = row + krow - 1
                                realCol::Int = col + kcol - 1
                                (realRow < 1 || realCol < 1) && continue
                                value = inputs[inputdims[1], realRow, realCol]
                                ####

                                minval = min(minval, value)
                            end
                        end
                        outputs[outputdims[1], row, col] = minval
                    end)))
end






