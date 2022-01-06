include("../Computation/Computation.jl")
import Main.Computation

function test(device)
    pb = Computation.ProgramBuilder(device)
    
    arr5_ptr = Computation.prealloc_global!(pb, :MyGlobal, Float64, 10)
    arr1_ptr = Computation.prealloc_stack!(pb, Int, 1)
    arr3_ptr = Computation.prealloc_readonly!(pb, collect(5:10))
    arr2_ptr = Computation.prealloc_stack!(pb, UInt32, 5)
    arr4_ptr = Computation.prealloc_unique!(pb, Int32, 5)

    pb() 

    arr1 = arr1_ptr()
    arr2 = arr2_ptr()
    arr3 = arr3_ptr()
    arr4 = arr4_ptr()
    arr5 = arr5_ptr()

    arr5[1:10] = collect(1.0:10.0)
    arr1[1] = typemax(Int)
    arr4[1:5] = collect(25:29)
    arr2[1:5] = collect(1:5)


    @assert arr1[1] == typemax(Int)  "Invalid Stack Mapping"
    @assert arr2 == collect(1:5)  "Invalid Stack Mapping"
    @assert arr3 == collect(5:10)  "Invalid Readonly Mapping"
    @assert arr4 == collect(25:29)  "Invalid Unique Mapping"
    @assert Int.(round.(arr5)) == collect(1:10)  "Invalid Global Mapping"
end

function test_devices()
    println("Starting Device Program Test....")
    for device in Computation.get_devices()
        println("\tChecking $device")
        test(device)
        println("\tSuccesfully Completed $device")
    end
    println("Successfully Compeleted Device Program Test!")
end

test_devices()