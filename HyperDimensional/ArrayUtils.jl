export buffer_remove_row

"""Shifts Array Up rather then allocating a new array
   Returns the new array length (DO NOT USE length(array) after using this function as it is useless)

   TODO: Generialized Solution
"""
function buffer_remove_row(array::AbstractArray{T, N}, removable_parts, true_array_len) where T where N
      if length(removable_parts) == 0; return (array, true_array_len); end
      dimensions = N
      placement_index = minimum(removable_parts)
      index_vector = collect(placement_index:true_array_len)
      for r in 1:length(removable_parts)
            rem = removable_parts[r]
            if rem <= true_array_len
                  deleteat!(index_vector, rem - placement_index - r + 2)
            end
      end
      new_len = size(array, 1) - length(removable_parts)
      for i in index_vector
            if N == 1
                  array[placement_index] = array[i]
            elseif N == 2
                  array[placement_index, 1:end] = array[i, 1:end]
            elseif N == 3
                  array[placement_index, 1:end, 1:end] = array[i, 1:end, 1:end]
            elseif N == 4
                  array[placement_index, 1:end, 1:end, 1:end] = array[i, 1:end, 1:end, 1:end]
            end
            placement_index += 1
      end
      return (array, new_len)
end
