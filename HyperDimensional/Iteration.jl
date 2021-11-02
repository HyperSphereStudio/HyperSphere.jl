""" High Dimensional Iteration
      Performs an iteration over length(param_1) dimensions, with the value at param_1 being number of times in that dimension
      Leftward direction means that the direction of iteration is going left
            For Example [1, 1, 1] -> [1, 1, 2] if forward direction
      Forward direction means incrementing positively
            For Example [1, 1, 2] -> [1, 1, 1] if left direction
"""
function hditer(length_vector::Vector{T}, iteration_lambda::Function; start_vec=nothing, leftward=true, forward=true) where T
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
                  iteration_lambda(index_vector, total_iteration)
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
"""
uhditer(num_dimensions::Integer, num_times::Integer, iteration_lambda::Function; start_vector=nothing, left_dir=true, forward_dir=true) = hditer(fill(num_times, num_dimensions), iteration_lambda, start_vec = start_vector, leftward = left_dir, forward = forward_dir)

function flatten_hditer(length_vector::Vector{T}, index_vector::Vector{T}) where T
      sum = 0
      for i in 1:length(index_vector)
            sum += index_vector[i] * length_vector[i] ^ i
      end
      sum
end

function flatten_uhditer(base, index_vector::Vector{T}) where T
      sum = 0
      for i in 1:length(index_vector)
            sum += index_vector[i] * base ^ i
      end
      sum
end

total_count(base, count) = (base ^ count)
