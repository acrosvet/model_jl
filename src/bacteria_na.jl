# Define agent =====================================================================================

using Random: MersenneTwister

"""
Agent type - BacterialAgent
"""
mutable struct BacterialAgent 
    id::Int16
    pos::CartesianIndex{2}
    status::Int8 # 0 = Susceptible, 1 = Pathogenic, 2 = Resistant, 3 = Exposed pathogenic, 4 = Exposed resistant, 5 = Carrier pathogenic, 6 = Carrier resistant, 7 =  Recovered pathogenic, 8 = Recovered resistant
    fitness::Float16
    neighbours::Array{CartesianIndex,8}
end

"""
Container for model
"""
mutable struct BacterialModel
    id::Int32
    timestep::Int16
    pop_r::Float32
    pop_s::Float32
    pop_p::Float32
    pop_d::Float32
    nbact::Int16
    colonies::Array
    total_status::Int8
    days_treated::Int8
    days_exposed::Int8
    days_recovered::Int16
    stress::Bool
    seed::Int8
    rng::MersenneTwister
end

#Utility ====================================================================================
"""
count_colonies!
Count the number of each type of bacterial colony in an animal host
"""
function count_colonies!(bacterialSubmodel)


    pop_r = 0.0
    pop_s = 0.0
    pop_p = 0.0
    pop_d = 0.0

    for colony in 1:length(bacterialSubmodel.colonies)
        if bacterialSubmodel.colonies[colony].status == 0
            pop_s += 1
        elseif bacterialSubmodel.colonies[colony].status == 1
            pop_p += 1
        elseif  bacterialSubmodel.colonies[colony].status == 2
            pop_r += 1
        elseif bacterialSubmodel.colonies[colony].status == 10
            pop_d += 1
        end
    end
    

    total_pop = pop_p + pop_s + pop_r

    bacterialSubmodel.pop_p = pop_p/total_pop
    bacterialSubmodel.pop_r = pop_r/total_pop
    bacterialSubmodel.pop_s = pop_s/total_pop
    bacterialSubmodel.pop_d = pop_d


end

# Initialise agents ==================================================================================

function initialiseBacteria(;
    animalno::Int16 = AnimalAgent.id,
    nbact::Int16 = Int16(1000),
    total_status::Int8 = Int8(0),
    days_treated::Int8 = Int8(0),
    days_exposed::Int8 = Int8(0),
    days_recovered::Int8 = Int8(0),
    stress::Bool = false,
    seed::Int8 = Int8(42),
    timestep::Int16 = Int16(0),
    rng::MersenneTwister = MersenneTwister(seed))


    # Agent space =========================================================================================

    colonies = Array{BacterialAgent}(undef, 33,33)

    #Create the initial model properties ==========================================================================

    pop_r = 0.0
    pop_s = 0.0
    pop_p = 0.0
    pop_d = 0.0 

    id = animalno


    #Set up the model
   bacterialSubmodel = BacterialModel(id, timestep, pop_r, pop_s, pop_p, pop_d, nbact, colonies, total_status, days_treated, days_exposed, days_recovered, stress, seed, rng)
     
    # Set bacterial fitnesses --------------------------------

    fitnesses = [rand(bacterialSubmodel.rng, 0.90:0.01:1.0), rand(bacterialSubmodel.rng, 0.90:0.01:1.0), rand(bacterialSubmodel.rng, 0.90:0.01:1.0)]

    function set_fitness(fitnesses, status)
        if status == 0
            fitnesses[1]
        elseif status == 1
            fitnesses[2]
        else 
            fitnesses[3]
        end
    end
# Set up the initial state of the model  

    #For pathogenic animals --------------------------

    if bacterialSubmodel.total_status == 1
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = i % 2 == 0 ? 1 : 0
            fitness = set_fitness(fitnesses, status)
            neighbours = Array{CartesianIndex, 8}
            colony = BacterialAgent(id, pos, status, fitness, neighbours)
            colonies[i] = colony
        end

    #For resistant animals ----------------------------
    elseif bacterialSubmodel.total_status == 2
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = i % 2 == 0 ? 2 : 0
            fitness = set_fitness(fitnesses, status)
            neighbours = Array{CartesianIndex, 8}
            colony = BacterialAgent(id, pos, status, fitness, neighbours)
            colonies[i] = colony
        end
    else 
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = 0
            fitness = set_fitness(fitnesses, status)
            neighbours = Array{CartesianIndex, 8}
            colony = BacterialAgent(id, pos, status, fitness, neighbours)
            colonies[i] = colony
        end
    end



    #Determine the population proportions of each bacterial type
    count_colonies!(bacterialSubmodel)

return bacterialSubmodel

end

@time bacterialSubmodel =  initialiseBacteria(animalno = Int16(100), nbact = Int16(33*33), total_status = Int8(1), days_treated = Int8(0), days_exposed = Int8(0), days_recovered = Int8(0), stress = false, seed = Int8(42))

"""
bact_treatment!
Bacteria respond to treatment
"""
function bact_treatment!(bacterialSubmodel)

    bacterialSubmodel.days_treated == 0 && return


    for colony in 1:length(bacterialSubmodel.colonies)
        if bacterialSubmodel.colonies[colony].status ≤ 1 #For susceptible and sensitive
            if rand(bacterialSubmodel.rng)  < ℯ^(-bacterialSubmodel.days_treated/20)
                if rand(bacterialSubmodel.rng) < 0.5
                    bacterialSubmodel.colonies[colony].status = 10#10 is dead
                    bacterialSubmodel.colonies[colony].fitness = 0
                end
            end    
        end
    end
    
end

"""
neighbours()
return neighbouring elements in a matrix 
"""
function neighbours!(pos)

        n1 = pos - CartesianIndex(1,0)
        n2 = pos + CartesianIndex(1,0)
        n3 = pos - CartesianIndex(0,1)
        n4 = pos + CartesianIndex(0,1)
        n5 = pos + CartesianIndex(1,1)
        n6 = pos - CartesianIndex(1,1)

    end
    
end

"""
bact_timestep!
Update attributes over time
"""
function bact_step!(bacterialSubmodel)
    bact_treatment!(bacterialSubmodel) #Apply treatment
    count_colonies!(bacterialSubmodel)#Update the population
    bacterialSubmodel.timestep += 1#Step through time
end
            
                
bacterialSubmodel.days_treated = 1


bact_step!(bacterialSubmodel)
