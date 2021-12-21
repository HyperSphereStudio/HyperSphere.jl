using Combinatorics
using BenchmarkTools
using Main.HyperSphere.HSMath

export hditer, uhditer, flatten_uhditer, flatten_hditer, total_count, sum_comb, unflatten_uhditer, unflatten_hditer, partition, partition_test, partition

""" High Dimensional Iteration
      Performs an iteration over length(param_1) dimensions, with the value at param_1 being number of times in that dimension
      Leftward direction means that the direction of iteration is going left
            For Example [1, 1, 1] -> [1, 1, 2] if forward direction
      Forward direction means incrementing positively
            For Example [1, 1, 2] -> [1, 1, 1] if left direction

      iteration_lambda(index_vector::AbstractArray{T}, total_iteration::Integer)::Bool
      Return true when it should stop
"""
function hditer(length_vector::AbstractArray{T}, iteration_lambda::Function; start_vec=nothing, leftward=true, forward=true) where T
      start_vector::Vector{T} = forward ? (@nullc(start_vec, ones(T, length(length_vector)))) : (@nullc(start_vec, copy(length_vector)))
      index_vector::Vector{T} = copy(start_vector)
      current_index::Int64 = leftward ? 1 : length(length_vector)
      trig_idx::Int64 = leftward ? length(length_vector) : 1
      rldirection::Int64 = leftward ? -1 : 1
      fbdirction::Int64 = forward ? 1 : -1
      total_iteration::Int64 = forward ? 1 : ∏(length_vector)

      @label reset
      for i in (forward ? (index_vector[current_index]:length_vector[current_index]) : 1:index_vector[current_index])
            if current_index != trig_idx
                  current_index -= rldirection
                  @goto reset
            else
                  if iteration_lambda(index_vector, total_iteration)
                        return
                  end
                  index_vector[current_index] += fbdirction
                  total_iteration += fbdirction
            end
      end
      if (leftward && current_index != 1) || (!leftward && (current_index < length(length_vector)))
            index_vector[current_index] = start_vector[current_index]
            current_index += rldirection
            index_vector[current_index] += fbdirction
            @goto reset
      end
end

""" Uniform High Dimensional Iteration
    Performs an iteration over param_1 dimensions, param_2 times
    iteration_lambda(index_vector::AbstractArray{T}, total_iteration::Integer)::Bool
       Return true when it should end
"""
uhditer(num_dimensions::Integer, num_times::Integer, iteration_lambda::Function; start_vec=nothing, left_dir=true, forward_dir=true) = hditer(fill(num_times, num_dimensions), iteration_lambda, start_vec = start_vec, leftward = left_dir, forward = forward_dir)


""" Inverse function of hyper index flattener
"""
function unflatten_uhditer(base, flattenedID::T) where T <: Integer
      indexes = T[]
      id = floor(flattenedID / base)
      new_id = 0
      while (new_id = id / base) > 0
            push!(indexes, id % base + 1)
            id = floor(new_id)
      end
      indexes
end

""" Inverse function of hyper index flattener
    Does not work atm
"""
function unflatten_hditer(dim_count, flattenedID::T; prime_list=HSMath.gen_n_primes(dim_count + 1)) where T <: Integer
      indexes = zeros(T, dim_count)
      id = floor(flattenedID / prime_list[end])
      new_id = 0
      index = 0
      while index < dim_count && (new_id = id / prime_list[end - index]) > 0
            println("", id)
            indexes[index + 1] = id % prime_list[end - index] + 1
            id = floor(new_id)
            index += 1
      end
      indexes
end

function flatten_hditer(index_vector::AbstractArray{T}; prime_list=HSMath.gen_n_primes(length(index_vector) + 1)) where T
      sum = 0
      for i in 1:length(index_vector)
            sum += (index_vector[i] - 1) * prime_list[i + 1] ^ i
      end
      sum
end

function flatten_uhditer(base, index_vector::AbstractArray{T}) where T
      sum = 0
      for i in 1:length(index_vector)
            sum += (index_vector[i] - 1) * base ^ i
      end
      sum
end

total_count(base, count) = (base ^ count)

"""   Function that iterates a n length vector such that the combination sum is always equal to k and all elements are the natural numbers
    . Invokes lambda function on every iteration
      iteration_lambda (index_vector::Vector{T}, total_iteration::T)::Bool
            Return true when it should end
            Returns if it was stopped or not
"""
function partition(n::T, iteration_lambda::Function)::Bool where T
      max_vector = zeros(T, n)
      sum_vector = zeros(T, n)
      index_vector = zeros(T, n)
      for i in 1:n
            partition(n, i, iteration_lambda, max_vector=max_vector, sum_vector=sum_vector, index_vector=index_vector)
            fill(0, max_vector)
            fill(0, sum_vector)
            fill(0, index_vector)
      end
      return false
end

"""   Function that iterates a n length vector such that the combination sum is always equal to k and all elements are the natural numbers
    . Invokes lambda function on every iteration
      iteration_lambda (index_vector::Vector{T}, total_iteration::T)::Bool
            Return true when it should end
      Returns if it was stopped or not
"""
function partition(k::T, n::T, iteration_lambda::Function; max_vector=nothing, sum_vector=nothing, index_vector=nothing)::Bool where T
      if n > 0
            if n == 1
                  return iteration_lambda([k], 1)
            end
            max_vector = max_vector === nothing ? zeros(T, n) : max_vector
            sum_vector = sum_vector === nothing ? zeros(T, n) : sum_vector
            index_vector = index_vector === nothing ? zeros(T, n) : index_vector
            current_index_index::T = 1
            total_iteration::T = 1
            max_vector[1] = k
            index_vector[1] = max(0, -(k * (n - 1)))

            @label reset
            if index_vector[current_index_index] <= max_vector[current_index_index]
                  if current_index_index != n
                        current_index_index += 1
                        sum_vector[current_index_index] = sum_vector[current_index_index - 1] + index_vector[current_index_index - 1]
                        index_vector[current_index_index] = max(0, -(k * (n - current_index_index - 1) + sum_vector[current_index_index]))
                        max_vector[current_index_index] = k - sum_vector[current_index_index]
                  else
                        if iteration_lambda(index_vector, total_iteration)
                              return true
                        end
                        total_iteration += 1
                        index_vector[end] += 1
                  end
                  @goto reset
            end
            if current_index_index != 1
                  current_index_index -= 1
                  index_vector[current_index_index] += 1
                  @goto reset
            end
      end
      return false
end


function partition_test(sum)
      t = time()
      out_array = [1]
      partition(sum, function(x, idx)
          out_array[1] = x[1]
          return false
      end)
      println("", "HyperSphere Completed in " * string(time() - t))
      t = time()
      x = collect(partitions(sum))
      println("", "Paritition Completed in " * string(time() - t))
      return (out_array, x)
end
