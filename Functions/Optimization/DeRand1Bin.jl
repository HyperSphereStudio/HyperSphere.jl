"Adapted From: https://machinelearningmastery.com/differential-evolution-from-scratch-in-python/"
#Written By Johnathan Bizzano

export diffevorandomsinglebin

#Mutate the genes
function mutate(a, b, c, result_array, scalefactor)
    for i in 1:length(a)
        result_array[i] = a[i] + scalefactor * (b[i] - c[i]) 
    end
end

#Clip the mutated genes
function clip(mutated, bounds)
    for i in 1:length(mutated)
        if mutated[i] < bounds[i].lower_bound
            mutated[i] = bounds[i].lower_bound
        elseif mutated[i] > bounds[i].upper_bound
            mutated[i] = bounds[i].upper_bound
        end
    end
end

#Perform gene binomial crossover
function crossover(mutated, target, dim_count, cr)
    i = 1
    for r in rand(dim_count)
        if r >= cr
            mutated[i] = target[i]
        end
        i += 1
    end
end

function choose_individual(population, excluded_individuals...)
    choice = rand(1:length(population))
    while choice in excluded_individuals
        choice = rand(1:length(population))
    end
    choice
end

struct Bound{T <: Number}
    lower_bound::T
    upper_bound::T
    Bound{T}(lower_bound, upper_bound) where T = new{T}(T(lower_bound), T(upper_bound))
    Bound(lower_bound::T, upper_bound::T) where T = new{T}(lower_bound, upper_bound)
end


"Differential Evolution of DeRand1Bin algorithm. ScaleFactor ∈ [0, 2]. CrossoverRate ∈ [0, 1]"
function diffevorandomsinglebin(error_func, initial_values::Array{T, 1}, bounds::Array{Bound{T}, 1}, population_size::Int, iterations::Int; scalefactor = .8, crossoverrate = .7, rnginterval = 1E-8) where T
    (scalefactor > 2 || scalefactor < 0) && error("Scale Factor ∈ [0, 2]")
    (crossoverrate > 1 || crossoverrate < 0) && error("Cross Over Rate ∈ [0, 1]")
    (population_size < 4) && error("Population Size Must Be > 3")

    dims = length(initial_values)
    tempArray = zeros(T, dims)
    
    #Create Population with Initial Values
    population = Array{Array{T, 1}, 1}(undef, population_size)
    population[1] = initial_values
    for i in 2:population_size
        population[i] = zeros(T, dims)
        for d in 1:dims
            population[i][d] = rand(bounds[d].lower_bound:rnginterval:bounds[d].upper_bound)
        end
    end

    #Init Eval
    errors = [error_func(ind) for ind in population]
 
    #Find the Best Init Performer
    best_idx = argmin(errors)
    best_ind = population[best_idx]
    best_error = errors[best_idx]
    prev_error = best_error

    for i in 1:iterations
        #Iterate all current Solutions
        for j in 1:population_size
            selected = population[j]
            #Choose Three Individuals in Population (Not Current)
            idx1 = choose_individual(population, j)
            idx2 = choose_individual(population, j, idx1)
            idx3 = choose_individual(population, j, idx1, idx2)
            
            mutate(population[idx1], population[idx2], population[idx3], tempArray, scalefactor)
            clip(tempArray, bounds)
            crossover(tempArray, selected, dims, crossoverrate)

            #Check to see if crossover was better then current individual
            crossover_error = error_func(tempArray)
            if crossover_error < error_func(selected)
                copy!(selected, tempArray)
                errors[j] = crossover_error
            end
        end

        #Check Best Performer in this iteratation
        best_idx = argmin(errors) 
        if errors[best_idx] < prev_error
            best_ind = population[best_idx]
            prev_error = errors[best_idx]
        end
    end

    return best_ind
end