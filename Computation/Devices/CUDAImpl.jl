using CUDA

export CUDADevice

struct CUDADevice <: Device end
Computation.name(device::CUDADevice) = :CUDA
Computation.alloc(device::CUDADevice, array::AbstractArray) = CuArray(array)
Computation.arraytype(device::CUDADevice) = CuArray
Computation.alloc(device::CUDADevice, T::Type, indxs...) = CuArray{T}(undef, indxs)