export Signature, MemorySettings, MemoryWrapper, Sig

Sig(name::Symbol) = Signature(name)

struct Signature
    name::Symbol
    Base.string(x::Signature) = "Function:$(x.name)"
end

"Contains the settings for a function to utilize in compilation"
struct MemorySettings
    storageType::Type
    inputType::Type
    outputType::Type
    device::Device
    deviceArray::Type

    MemorySettings() = MemorySettings(Double, Double, Double, CPUDev, Array)

    MemorySettings(storageType::Type, inputType::Type, outputType::Type, device::Device, deviceArray::Type) = 
        MemorySettings(storageType, inputType, outputType, device, deviceArray)

    MemorySettings(settings::MemorySettings; storageType=settings.storageType, 
                   inputType=settings.inputType, outputType=settings.outputType, 
                   device=settings.device) = 
            MemorySettings(storageType, inputType, outputType, device, arraytype(settings.device))
end        

"Wrapper designed to take in memory settings and return some form of object with those settings builtin"
struct MemoryWrapper{ReturnType}
    sig::Signature
    fun::Function
    
    MemoryWrapper{R}(sig::Signature, fun::Function) where R = new{R}(sig, fun)

    function (wrapper::MemoryWrapper)(settings::MemorySettings)
        return wrapper.fun(settings)
    end
end