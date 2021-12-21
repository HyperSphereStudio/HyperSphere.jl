export BPoint, cartesian, cross, angle_vector, project, angle_scalar, ×, unit, norm_angles, dim_count

struct BPoint
    ρ::Float64
    angles::Array{Float64, 1}

    function BPoint(length, angles::T...) where T <: Number
        new(Float64(length), Float64[Float64(angle) for angle in angles])
    end

    BPoint(length, angles::Array{Float64, 1}) = new(Float64(length), angles)
    BPoint(n::Number) = new(Float64(n), [0])

    "Convert Cartesian to Spherical"
    function BPoint(coordinates::Array{Float64, 1})
        ρ::Float64 = 0
        for coord in coordinates
            ρ += coord ^ 2
        end

        partialp = p
        p = sqrt(p)

        addPI = coordinates[end] < 0
        deleteat!(coordinates, length(coordinates))

        for i in 1:length(coordinates)
            value = acos(coordinates[i] / sqrt(partialp))
            partialp -= coordinates[i] ^ 2
            coordinates[i] = value
        end

        if addPI
            coordinates[end] = 2 * pi - coordinates[end]
        end

        BPoint(p, coordinates)
    end


    Base.length(p::BPoint) = p.ρ

    Base.:+(p::BPoint, n::Number)::BPoint = BPoint(p.ρ + n, p.angles)
    Base.:-(p::BPoint, n::Number)::BPoint = BPoint(p.ρ - n, p.angles)
    Base.:*(p::BPoint, n::Number)::BPoint = BPoint(p.ρ * n, p.angles)
    Base.:/(p::BPoint, n::Number)::BPoint = BPoint(p.ρ / n, p.angles)
    Base.:^(p::BPoint, pow::Number)::BPoint = BPoint(p.ρ ^ pow, p.angles)

    Base.:+(n::Number, p::BPoint)::BPoint = BPoint(p.ρ + n, p.angles)
    Base.:-(n::Number, p::BPoint)::BPoint = BPoint(n - p.ρ, p.angles)
    Base.:*(n::Number, p::BPoint)::BPoint = BPoint(p.ρ * n, p.angles)
    Base.:/(n::Number, p::BPoint)::BPoint = BPoint(n / p.ρ, p.angles)
    Base.:^(n::Number, pow::BPoint)::BPoint = BPoint(pow ^ p.ρ, p.angles)

    function Base.:+(p1::BPoint, p2::BPoint)::BPoint
        angles = norm_angles(p1, p2)
        unit_vector = unit(angles)
        return BPoint(project(p1, unit_vector).ρ + project(p2, unit_vector).ρ, angles)
    end

    function Base.:*(p1::BPoint, p2::BPoint)::BPoint
        angles = norm_angles(p1, p2)
        unit_vector = unit(angles)
        return BPoint(project(p1, unit_vector).ρ * project(p2, unit_vector).ρ, angles)
    end

    function Base.:/(p1::BPoint, p2::BPoint)::BPoint
        angles = norm_angles(p1, p2)
        unit_vector = unit(angles)
        return BPoint(project(p1, unit_vector).ρ / project(p2, unit_vector).ρ, angles)
    end

    function Base.:-(p1::BPoint, p2::BPoint)::BPoint
        angles = norm_angles(p1, p2)
        unit_vector = unit(angles)
        return BPoint(project(p1, unit_vector).ρ - project(p2, unit_vector).ρ, angles)
    end


end

dim_count(p)::Int64 = length(p.angles)

"Project p1 onto p2"
project(p1::BPoint, p2::BPoint)::BPoint = BPoint(p1.ρ * p2.ρ * cos(angle_scalar(p1, p2)), p2.angles)

"Convert to Cartesian"
function cartesian(p)::Array{Float64, 1}
     coordinates = zeros(Float64, dim_count(p) + 1)
     coordinates[1] = p.ρ * cos(p.angles[1])

     sin_product = p.ρ * sin(p.angles[1])
     for i in 2:(length(coordinates) - 1)
         coordinates[i] = sin_product * cos(p.angles[i])
         sin_product *= sin_product * sin(p.angles[i])
     end

     coordinates[end] = sin_product
     coordinates
end

"Angle Number Between Numbers"
function angle_vector(p1::BPoint, p2::BPoint)::Array{Float64, 1}
    check(p1, p2)
    angles = zeros(Float64, dim_count(p1))
    for i in 1:dim_count(p1)
        angles[i] = p1.angles[i] - p2.angles[i]
    end
    angles
end

angle_scalar(p1::BPoint, p2::BPoint)::Float64 = sum(angle_vector(p1, p2))

"Unit Number"
unit(p::BPoint)::BPoint = BPoint(1, p.angles)
unit(angles::Float64...)::BPoint = BPoint(1, collect(angles))
unit(angles::AbstractArray{Float64})::BPoint = BPoint(1, angles)

function check(p1::BPoint, p2::BPoint)
    if dim_count(p1) != dim_count(p2)
        throw(DimensionMismatch("Dimension Mismatch between $p1 and $p2"))
    end
end

"Normalized Angles"
function norm_angles(p1::BPoint, p2::BPoint)::Array{Float64, 1}
    check(p1, p2)
    angles = zeros(Float64, dim_count(p1))
    for i in 1:dim_count(p1)
        angles[i] = (p1.ρ * p1.angles[i] + p2.ρ * p2.angles[i]) / (p1.ρ + p2.ρ)
    end
    angles
end

"Cross Product"
function ×(p1::BPoint, p2::BPoint)::BPoint
    check(p1, p2)
    angle_add = angle_scalar(p1, p2) > pi ? true : false
    anglev = angle_vector(p1, p2)
    for i in 1:dim_count(p1)
        anglev[i] = angle_add ? anglev[i] - (pi/2) : anglev[i] + (pi/2)
    end

    #TODO Change to be area of parallelpid
    return BPoint(p1.ρ * p2.ρ, anglev)
end

cross(p1::BPoint, p2::BPoint)::BPoint = p1 × p2
