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
    neighbours::Array{CartesianIndex}
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

# Container for data

mutable struct BacterialData
    timestep::Array{Int16}
    pop_r::Array{Float32}
    pop_s::Array{Float32}
    pop_p::Array{Float32}
    pop_d::Array{Float32}
end

bacterialData = BacterialData([0],[0.0],[0.0],[0.0],[0.0])
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


"""
get_neighbours()
return neighbouring elements in a matrix 
"""
function get_neighbours(pos)

    surrounding = Array{CartesianIndex}(undef, 8)    

    surrounding[1] = pos + CartesianIndex(-1,1)
    surrounding[2] = pos + CartesianIndex(0,1)
    surrounding[3] = pos + CartesianIndex(1,1)
    surrounding[4] = pos + CartesianIndex(1,0)
    surrounding[5] = pos + CartesianIndex(1,-1)
    surrounding[6] = pos + CartesianIndex(0,-1)
    surrounding[7] = pos + CartesianIndex(-1,-1)
    surrounding[8] = pos + CartesianIndex(-1,0)


    return surrounding
   
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
            neighbours = get_neighbours(pos)
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
            neighbours = get_neighbours(pos)
            colony = BacterialAgent(id, pos, status, fitness, neighbours)
            colonies[i] = colony
        end
    else 
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = 0
            fitness = set_fitness(fitnesses, status)
            neighbours = get_neighbours(pos)
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
bact_repopulate!
Repopulate after treatment
"""
function bact_repopulate!(bacterialSubmodel)

    bacterialSubmodel.pop_d == 0 && return

    for i in 1:length(bacterialSubmodel.colonies)
        if bacterialSubmodel.colonies[i].status == 10
            competing_neighbour = bacterialSubmodel.colonies[i].neighbours[rand(bacterialSubmodel.rng,1:8)]
            if (competing_neighbour[1] > 0 && competing_neighbour[2] > 0) && (competing_neighbour[1] ≤ 33 && competing_neighbour[2] ≤ 33)
                if bacterialSubmodel.days_treated != 0 && bacterialSubmodel.total_status ≤ 1
                    if rand(bacterialSubmodel.rng) < 0.5
                        if bacterialSubmodel.colonies[competing_neighbour].status == 1
                            return
                        elseif bacterialSubmodel.colonies[competing_neighbour].status == 0
                            return
                        elseif bacterialSubmodel.colonies[competing_neighbour].status == 2
                            bacterialSubmodel.colonies[i].status = 2
                        end
                    end
                elseif bacterialSubmodel.days_treated == 0 && bacterialSubmodel.total_status ≤ 1
                    if rand(bacterialSubmodel.rng) < 0.5
                        bacterialSubmodel.colonies[i].status = bacterialSubmodel.colonies[competing_neighbour].status
                    end
                end
            end    
        end
    end
end

"""
bact_export!
Export bacterial data
"""
function bact_export!(bacterialSubmodel, bacterialData)
    push!(bacterialData.timestep, bacterialSubmodel.timestep)
    push!(bacterialData.pop_r, bacterialSubmodel.pop_r)
    push!(bacterialData.pop_s, bacterialSubmodel.pop_s)
    push!(bacterialData.pop_p, bacterialSubmodel.pop_p)
    push!(bacterialData.pop_d, bacterialSubmodel.pop_d)
end


"""
bact_timestep!
Update attributes over time
"""
function bact_step!(bacterialSubmodel, bacterialData)
    bact_treatment!(bacterialSubmodel) #Apply treatment
    bact_repopulate!(bacterialSubmodel)#Replace bacteria killed by treatment
    count_colonies!(bacterialSubmodel)#Update the population
    bact_export!(bacterialSubmodel, bacterialData)
    bacterialSubmodel.timestep += 1#Step through time
end
            
                
bacterialSubmodel.days_treated = 0


 bact_step!(bacterialSubmodel, bacterialData)

@time [bact_step!(bacterialSubmodel, bacterialData) for i in 1:1825]
