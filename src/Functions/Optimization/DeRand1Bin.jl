"Adapted From: https://machinelearningmastery.com/differential-evolution-from-scratch-in-python/"
#Written By Johnathan Bizzano

export diffevorandomsinglebin

#Mutate the genes
function mutate(a, b, c, scalefactor)
    return a + scalefactor * (b - c) 
end

#Perform gene binomial crossover & clip the mutated genes
function clipNCrossover(mutated, lower_bound, upper_bound, target, cr)
    if rand() >= cr
        return target
    end
    if mutated < lower_bound
        return lower_bound
    elseif mutated > upper_bound
        return upper_bound
    end
    return mutated
end

function choose_individual(population, excluded_individuals...)
    choice = rand(1:length(population))
    while choice in excluded_individuals
        choice = rand(1:length(population))
    end
    choice
end

init_rand(lower_bound, upper_bound, rnginterval) = rand(lower_bound:rnginterval:upper_bound)


"Differential Evolution of DeRand1Bin algorithm. ScaleFactor ∈ [0, 2]. CrossoverRate ∈ [0, 1]"
function diffevorandomsinglebin(device::Device, error_func::Problem, initial_values::AbstractArray{T}, 
            lower_bound::T, upper_bound::T, population_size::Int, iterations::Int; 
            scalefactor = .8, crossoverrate = .7, rnginterval = 1E-8, IsVerbose=true) where T

    (scalefactor > 2 || scalefactor < 0) && error("Scale Factor ∈ [0, 2]")
    (crossoverrate > 1 || crossoverrate < 0) && error("Cross Over Rate ∈ [0, 1]")
    (population_size < 4) && error("Population Size Must Be > 3")

    dims = length(initial_values)
    mutated = alloc(device, T, dims)
    
    #Create Population with Initial Values as first entry
    population = alloc(device, population_size, dims)
    copy!(view(population, 1, 1:dims), initial_values)

    #Initialize Random
    broadcast!(init_rand, view(population, 2:population_size, dims), lower_bound, upper_bound, rnginterval)

    #Init Eval
    errors = [error_func(ind) for ind in population]
 
    #Find the Best Init Performer
    best_idx = argmin(errors)
    best_error = errors[best_idx]
    prev_error = best_error

    for i in 1:iterations
        #Iterate all current Solutions
        for j in 1:population_size
            selected = view(population, j, 1:dims)
            #Choose Three Individuals in Population (Not Current)
            idx1 = choose_individual(population, j)
            idx2 = choose_individual(population, j, idx1)
            idx3 = choose_individual(population, j, idx1, idx2)
        
            broadcast!(mutate, mutated, view(population, idx1, 1:dims), view(population, idx2, 1:dims), view(population, idx3, 1:dims), scalefactor)
            broadcast!(clipNCrossover, mutated, lower_bound, upper_bound, selected, crossoverrate)

            #Check to see if crossover was better then current individual
            crossover_error = error_func(mutated)
            if crossover_error < error_func(selected)
                copy!(selected, mutated)
                errors[j] = crossover_error
            end
        end

        #Check Best Performer in this iteratation
        idx = argmin(errors) 
        if errors[idx] < prev_error
            prev_error = errors[idx]
            best_error = prev_error
            best_idx = idx
        end
        
        (IsVerbose) && println("Iter:$i. Best Error:$best_error")
    end

    return (population[best_idx], best_error)
end