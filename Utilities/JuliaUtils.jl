macro nullc(value, if_null)
      return esc(:($value == nothing ? $if_null : $value))
end
