export ProgramBuilder, Program, ProgramMemory, prealloc_readonly!, prealloc_unique!, prealloc_stack!, get_global_ptr

struct ArrayDetails{N}
    dims::NTuple{N, Int}
    type::Type

    ArrayDetails(dims::NTuple{N, Int}, type::Type) where N = new{N}(dims, type)
end

mutable struct ProgramBuilder
    device::Device
    readonly_memory::Vector{AbstractArray}
    global_memory::Vector{Pair{Symbol, ArrayDetails}}
    unique_memory::Vector{ArrayDetails}
    current_stack_size::Int
    
    readonly_size::Int
    unique_memory_size::Int
    global_memory_size::Int
    memory_size::Int
    max_stack_size::Int

    parent_ref

    ProgramBuilder(device::Symbol) = ProgramBuilder(get_device(device))
    ProgramBuilder(device::Device) = new(Function[], device, AbstractArray[], Pair{Symbol, ArrayDetails}[], ArrayDetails[], 0, 0, 0, 0, 0, 0, nothing)

    (p::ProgramBuilder)() = Program(p)
end

function getarray(memory_block, type, offset, dims)
    len = prod(dims) * sizeof(type)
    return (reshape(reinterpret(type, view(memory_block, offset:(offset + len - 1))), dims...), offset + len)
end

const ReadonlyMemType = 1
const UniqueMemType = 2
const GlobalMemType = 3
const StackMemType = 4

struct PrealloctionPointer
    type::Int
    index
    pb::ProgramBuilder

    PrealloctionPointer(type::Int, index, pb::ProgramBuilder) = new(type, index, pb)

    function (p::PrealloctionPointer)()
        (p.pb.parent_ref === nothing) && error("Cannot get array as program has not finished building!")
        (p.type == ReadonlyMemType) && return p.pb.parent_ref.readonly_memory[p.index]
        (p.type == UniqueMemType) && return p.pb.parent_ref.unique_memory[p.index]
        (p.type == GlobalMemType) && return p.pb.parent_ref.global_memory[p.index]
        if p.type == StackMemType
            init = p.index[1]
            range = init:(init + prod(p.index[3]) * sizeof(p.index[2]) - 1)
            return reshape(reinterpret(p.index[2], view(p.pb.parent_ref.stack, range)), p.index[3]...)
        end
        error("Unknown Memory Pointer Type")
    end
end

Base.push!(pb::ProgramBuilder, fun::Function) = push!(pb.programs, fun)


"Get a pointer accessing global memory"
get_global_ptr(pb::ProgramBuilder, sym::Symbol) =  PrealloctionPointer(GlobalMemType, sym, pb)

"Preallocate readonly memory. Will optimize globally in the program to reduce memory"
function prealloc_readonly!(pb::ProgramBuilder, array)
    idx = findfirst([item == array for item in pb.readonly_memory])
    if idx === nothing
        push!(pb.readonly_memory, array)
        pb.readonly_size += length(array) * sizeof(eltype(array))
        idx = length(pb.readonly_memory)
    end
    return PrealloctionPointer(ReadonlyMemType, idx, pb)
end

"Preallocate unique memory that nothing else is allowed to use. Can Read/Write"
function prealloc_unique!(pb::ProgramBuilder, type::Type, dims...)
    push!(pb.unique_memory, ArrayDetails(dims, type))
    pb.unique_memory_size += prod(dims) * sizeof(type)
    return PrealloctionPointer(UniqueMemType, length(pb.unique_memory), pb)
end

"Preallocate global memory that anything can read/write to"
function prealloc_global!(pb::ProgramBuilder, sym::Symbol, type::Type, dims...)
    push!(pb.global_memory, Pair(sym, ArrayDetails(dims, type)))
    pb.global_memory_size += prod(dims) * sizeof(type)
    return PrealloctionPointer(GlobalMemType, sym, pb)
end

"Preallocate stack memory. Will be overwritten constantly. Only use for temporary information in a single threaded environment"
function prealloc_stack!(pb::ProgramBuilder, type::Type, dims...)
    out = PrealloctionPointer(StackMemType, (pb.current_stack_size + 1, type, dims), pb)
    pb.current_stack_size += prod(dims) * sizeof(type)
    return out
end


function Base.flush(pb::ProgramBuilder)
    pb.max_stack_size = max(pb.current_stack_size, pb.max_stack_size)
    pb.current_stack_size = 0
    pb.memory_size = pb.readonly_size + pb.global_memory_size + pb.unique_memory_size
end

struct ProgramMemory{ArrayType}
    readonly_memory::Array{ArrayType}
    unique_memory::Array{ArrayType}
    global_memory::Dict{Symbol, ArrayType}
    stack::ArrayType
    memory_block::ArrayType

    stack_size::Int
    readonly_size::Int
    unique_memory_size::Int
    global_memory_size::Int
    memory_size::Int

    function ProgramMemory(pb::ProgramBuilder)
        atype = arraytype(pb.device)
        offset = 1

        memory_block = alloc(pb.device, UInt8, pb.memory_size + pb.max_stack_size)
        stack = view(memory_block, (pb.memory_size + 1):length(memory_block))
        readonly_memory = Array{atype}(undef, length(pb.readonly_memory))
        unique_memory = Array{atype}(undef, length(pb.unique_memory))
        global_memory = Dict{Symbol, atype}()

        for idx in eachindex(pb.readonly_memory)
            arr = pb.readonly_memory[idx]
            arrmem = reinterpret(UInt8, arr)
            copyto!(memory_block, offset, arrmem)
            res = getarray(memory_block, eltype(arr), offset, size(arr))
            readonly_memory[idx] = res[1]
            offset = res[2]
        end

        for idx in eachindex(pb.unique_memory)
            res = getarray(memory_block, pb.unique_memory[idx].type, offset, pb.unique_memory[idx].dims)
            unique_memory[idx] = res[1]
            offset = res[2]
        end

        for glob in pb.global_memory
            res = getarray(memory_block, glob[2].type, offset, glob[2].dims)
            global_memory[glob[1]] = res[1]
            offset = res[2]
        end       

        new{atype}(readonly_memory, unique_memory, global_memory, stack, memory_block, pb.max_stack_size, pb.readonly_size, pb.unique_memory_size, pb.global_memory_size, pb.memory_size + pb.max_stack_size)
    end
end

mutable struct Program{ArrayType}
    device::Device
    mem::ProgramMemory{ArrayType}

    function Program(pb::ProgramBuilder)
        flush(pb)
        mem = ProgramMemory(pb)
        pb.parent_ref = mem
        new{arraytype(pb.device)}(pb.device, mem)
    end

    function (p::Program)(arg)
        return p.program(arg)
    end
end




