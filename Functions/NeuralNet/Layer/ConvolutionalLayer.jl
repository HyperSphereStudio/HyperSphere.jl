export ConvolutionalLayer2D

function ConvolutionalLayer2D(const_initializer; inputdims = (3, 1), kerneldims = (1, 1))
    return Wrapper(
        function (ST, IT, OT)
            outdims = (inputdims[1] - kerneldims[1], inputdims[2] - kernerldims[2])
            size = inputdims[1] * inputdims[2]

            #In order for conv layer to be same size, kernel must have offset
            row_offset = Int(ceil((kerneldims[1] / 2)))
            col_offset = Int(round((kerneldims[2] / 2)))
            Layer{ST, IT, OT, size, size}(kerneldims[1] * kerneldims[2], const_initializer, 
                Func{ST, IT, OT}(
                        function (constants, inputs, outputs)
                                #Matrix Iteration
                                for row in 1:outdims[1]
                                    for col in 1:outdims[2]

                                        #Kernel Dot SubMatrix
                                        sum::IT = 0
                                        for krow in 1:kerneldims[1]
                                            for kcol in 1:kerneldims[2]
                                                #Skip If Out of bounds
                                                ((row - krow) < row_offset || (col - kcol) < kcol_offset) && continue

                                                sum += constants[kerneldims[1], krow, kcol] * inputs[inputdims[1], row + krow - 1, col + kcol - 1]
                                            end
                                        end
                                        outputs[outdims[1], row, col] = sum
                                    end
                                end
                        end))
        end)
end



