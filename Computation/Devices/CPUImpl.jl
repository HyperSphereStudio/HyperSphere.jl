struct CPUDevice <: Device end

export CPUDevice

Computation.name(device::CPUDevice) = :CPU
Computation.alloc(device::CPUDevice, array::AbstractArray) = Array(array)
Computation.arraytype(device::CPUDevice) = Array
Computation.alloc(device::CPUDevice, T::Type, indxs...) = Array{T}(undef, indxs)