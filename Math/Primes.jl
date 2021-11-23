export isprime, nextprime, gen_n_primes, brute_next_factor, next_factor

using Main.HyperSphere.HSMath

function isprime(x::Int64)::Bool
        if x % 2 == 0; return false; end
        for i in 3:2:Int64(ceil(sqrt(x)))
                if x % i == 0; return false; end
        end
        return true
end

function nextprime(lastprime::Int64)
        if lastprime == 2; return 3; end
        lastprime += lastprime % 2 == 0 ? 1 : 2
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



function brute_next_factor(x::T)::T where T
        if x % 2 == 0
                return x == 2 ? 1 : 2
        elseif x % 3 == 0
                return x == 3 ? 1 : 3
        elseif x % 5 == 0
                return x == 5 ? 1 : 5
        end
        for i in 3:2:T(ceil(sqrt(x)))
                if i % 5 != 0 && x % i == 0; return T(i); end
        end
        return 1
end


"""Factoring Algorithm made by Johnathan Bizzano
   W is the diagnol offset such that (maxsqr + w)(maxsqr - w) = x
"""

function next_factor(x::T) where T <: Real
        if x % 2 == 0
                return x == 2 ? 1 : 2
        elseif x % 3 == 0
                return x == 3 ? 1 : 3
        elseif x % 5 == 0
                return x == 5 ? 1 : 5
        end
        last_factor = 7
        next_factor = 11
        last_func = x - last_factor * floor(x / last_factor)

        for i in 1:100
                func = x - next_factor * floor(x / next_factor)
                if func == 0 || isnan(next_factor)
                        return isnan(next_factor) ? 1 : next_factor
                end
                deriv = (func - last_func) / (next_factor - last_factor)
                last_func = func
                last_factor = next_factor
                next_factor -= func / (deriv)
        end

        return isnan(next_factor) ? 1 : (next_factor < 1 ? 1 : next_factor)
end

function next_factor(x::T) where T <: Complex
        if cplx_mod(x, 2) == 0
                return x == 2 ? 1 : 2
        elseif cplx_mod(x, 3) == 0
                return x == 3 ? 1 : 3
        elseif cplx_mod(x, 5) == 0
                return x == 5 ? 1 : 5
        end
        next_sqr_factor = cplx_ceil(sqrt(x))
        dist = next_sqr_factor * next_sqr_factor - x
        factor = next_sqr_factor - sqrt(next_sqr_factor * next_sqr_factor - x)
        if factor == cplx_floor(factor); return factor; end
        return 1
end
