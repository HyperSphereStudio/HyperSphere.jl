function isprime(x::Int64)::Bool
        if x % 2 == 0; return false; end
        for i in 3:2:Int64(ceil(sqrt(x)))
                if x % i == 0; return false; end
        end
        return true
end

function nextprime(lastprime::Int64)
        if lastprime == 2; return 3; end
        lastprime += 2
        while !isprime(lastprime); lastprime += 2; end
        return lastprime
end

function gen_n_primes(n::Int64)
        out = zeros(Int64, n)
        idx = 2
        out[1] = 2
        while idx < n + 1
                out[idx] = nextprime(out[idx - 1])
                idx += 1
        end
        return out
end
