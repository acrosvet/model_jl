# Define agent =====================================================================================

using Random: MersenneTwister
#using FLoops


"""
Agent type - BacterialAgent
"""
mutable struct BacterialAgent 
    id::Int
    pos::CartesianIndex{2}
    status::Int # 0 = Susceptible, 1 = Pathogenic, 2 = Resistant, 3 = Exposed pathogenic, 4 = Exposed resistant, 5 = Carrier pathogenic, 6 = Carrier resistant, 7 =  Recovered pathogenic, 8 = Recovered resistant
    fitness::Float16
    neighbours::Array{CartesianIndex}
    processed::Bool
end

"""
Container for model
"""
mutable struct BacterialModel
    id::Int
    timestep::Int
    pop_r::Float16
    pop_s::Float16
    pop_p::Float16
    pop_d::Float16
    nbact::Int
    colonies::Array{BacterialAgent}
    total_status::Int
    days_treated::Int
    days_exposed::Int
    days_recovered::Int
    days_carrier::Int
    stress::Bool
    seed::Int
    rng::MersenneTwister
    clinical::Bool
end

# Container for data

mutable struct BacterialData
    id::Array{Int}
    timestep::Array{Int}
    pop_r::Array{Float16}
    pop_s::Array{Float16}
    pop_p::Array{Float16}
    pop_d::Array{Float16}
end

#Utility ====================================================================================
"""
count_colonies!
Count the number of each type of bacterial colony in an animal host
"""
function count_colonies!(bacterialModel, colony )

        if colony.status == 0
            bacterialModel.pop_s += 1
        elseif colony.status == 1
            bacterialModel.pop_p += 1
        elseif  colony.status == 2
            bacterialModel.pop_r += 1
        elseif colony.status == 10
            bacterialModel.pop_d += 1
        end
    
    


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
    animalno::Int = AnimalAgent.id,
    nbact::Int = Int(1000),
    total_status::Int = Int(0),
    days_treated::Int = Int(0),
    days_exposed::Int = Int(0),
    days_recovered::Int = Int(0),
    stress::Bool = false,
    seed::Int = Int(42),
    timestep::Int = Int(0),
    rng::MersenneTwister = MersenneTwister(seed))


    # Agent space =========================================================================================



    colonies = Array{BacterialAgent}(undef, 33,33)

    #Create the initial model properties ==========================================================================

    pop_r = 0.0
    pop_s = 0.0
    pop_p = 0.0
    pop_d = 0.0 
    days_carrier = 0


    id = animalno

    clinical = false

    #Set up the model
   bacterialModel = BacterialModel(id, timestep, pop_r, pop_s, pop_p, pop_d, nbact, colonies, total_status, days_treated, days_exposed, days_recovered, days_carrier, stress, seed, rng, clinical)
     
    # Set bacterial fitnesses --------------------------------


# Set up the initial state of the model  

    #For pathogenic animals --------------------------

    if bacterialModel.total_status == 1
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = i % 2 == 0 ? 1 : 0
            status = i % 200 == 0 ? 2 : status
            fitness = rand(bacterialModel.rng, 0.98:0.001:0.99)
            neighbours = get_neighbours(pos)
            processed = false
            colony = BacterialAgent(id, pos, status, fitness, neighbours, processed)
            colonies[i] = colony
        end

    #For resistant animals ----------------------------
    elseif bacterialModel.total_status == 2
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = i % 2 == 0 ? 2 : 0
            status = i % 200 == 0 ? 2 : status
            fitness = rand(bacterialModel.rng, 0.97:0.001:0.99)
            neighbours = get_neighbours(pos)
            processed = false
            colony = BacterialAgent(id, pos, status, fitness, neighbours, processed)
            colonies[i] = colony
        end
    else 
        for i in 1:length(colonies)
            id = i
            pos = CartesianIndices(colonies)[i]
            status = 0
            fitness = rand(bacterialModel.rng, 0.98:0.001:0.99)
            neighbours = get_neighbours(pos)
            processed = false
            colony = BacterialAgent(id, pos, status, fitness, neighbours, processed)
            colonies[i] = colony
        end
    end



    bacterialModel.colonies = colonies

    #Determine the population proportions of each bacterial type
    
    bacterialModel.pop_r = 0
    bacterialModel.pop_s = 0
    bacterialModel.pop_p = 0
    bacterialModel.pop_d = 0
   
    count_colonies!.(Ref(bacterialModel), bacterialModel.colonies)#Update the population

    total_pop = bacterialModel.pop_r + bacterialModel.pop_s + bacterialModel.pop_p

    bacterialModel.pop_p = bacterialModel.pop_p/total_pop
    bacterialModel.pop_r = bacterialModel.pop_r/total_pop
    bacterialModel.pop_s = bacterialModel.pop_s/total_pop

return bacterialModel

end

@time bacterialModel =  initialiseBacteria(animalno = Int(100), nbact = Int(33*33), total_status = Int(2), days_treated = Int(0), days_exposed = Int(0), days_recovered = Int(0), stress = false, seed = Int(42))


"""
bact_treatment!
Bacteria respond to treatment
"""
function bact_treatment!(bacterialModel, colony)
    colony.processed == true && return

    bacterialModel.days_treated == 0 && return
    colony.status > 1 && return
    rand(bacterialModel.rng)  > ℯ^(-bacterialModel.days_treated/20) && return
    colony.status = 10
    colony.fitness = 0
    colony.processed = true 
end

"""
check_bounds(competing_neighbour)
return from boundary cases in the matrix, take the blue pill
"""
function check_bounds(competing_neighbour, min, max)

   if competing_neighbour[1] < min
    false
   elseif competing_neighbour[1] > max
       false
    elseif competing_neighbour[2] < min
        false
    elseif competing_neighbour[2] > max
        false
    end
end


"""
bact_repopulate!
Repopulate after treatment
"""
function bact_repopulate!(bacterialModel, colony)
    colony.processed == true && return

    bacterialModel.pop_d == 0 && return
    colony.status != 10 && return
    competing_neighbour = colony.neighbours[rand(bacterialModel.rng,1:8)]
    competing_neighbour[1] < 1  && return
    competing_neighbour[1] > 33 && return
    competing_neighbour[2] < 1 && return
    competing_neighbour[2] > 33 && return
    competing_neighbour = bacterialModel.colonies[competing_neighbour]
        if bacterialModel.days_treated != 0 && bacterialModel.total_status ≤ 1
            rand(bacterialModel.rng) ≥ 0.5 && return
            colony.status != 2 && return
            colony.status = 2
            colony.processed = true
            colony.fitness = competing_neighbour.fitness
        elseif bacterialModel.days_treated == 0 && bacterialModel.total_status ≤ 1
            rand(bacterialModel.rng) ≥ 0.5 && return
            colony.status = competing_neighbour.status
            colony.processed = true
            colony.fitness = competing_neighbour.fitness
        end

end



"""
bact_export!
Export bacterial data
"""
function bact_export!(bacterialModel, bacterialData)

    push!(bacterialData.id, bacterialModel.id)
    push!(bacterialData.timestep, bacterialModel.timestep)
    push!(bacterialData.pop_r, bacterialModel.pop_r)
    push!(bacterialData.pop_s, bacterialModel.pop_s)
    push!(bacterialData.pop_p, bacterialModel.pop_p)
    push!(bacterialData.pop_d, bacterialModel.pop_d)
end


         
"""
bact_carrier!
Set the bacterial population of carrier animals
"""
function bact_carrier!(bacterialModel, colony, carrier_level)

    total_status = bacterialModel.total_status
    total_status ∉ [5,6] && return
    colony.status = 0
    rand(bacterialModel.rng) > 0.25 && return
    if total_status == 6
            colony.status % carrier_level != 0 && return 
            colony.status = 2
            colony.processed = true
            colony.fitness = rand(bacterialModel.rng, 0.95:0.001:0.99)
    elseif total_status == 5
            colony.status % carrier_level != 0 && return 
            colony.status = 1
            colony.processed = true
            colony.fitness = rand(bacterialModel.rng, 0.98:0.001:0.99)
    end
end

"""
bact_fitness!
Competition between bacterial colonies
"""
function bact_fitness!(bacterialModel, colony)
    colony.processed == true && return
    colony.status == 0 && return
    competing_neighbour = colony.neighbours[rand(bacterialModel.rng,1:8)]

    competing_neighbour[1] < 1  && return
    competing_neighbour[1] > 33 && return
    competing_neighbour[2] < 1 && return
    competing_neighbour[2] > 33 && return


   competing_neighbour = bacterialModel.colonies[competing_neighbour]

        colony.fitness > competing_neighbour.fitness && return
        rand(bacterialModel.rng) ≥ 0.5 && return
            colony.status = competing_neighbour.status
            colony.fitness = competing_neighbour.fitness
end

"""
bact_processed
ensure bacteria do not get processed twice
"""
function bact_processed!(colony)
        colony.processed = false
end
"""
bact_timestep!
step bacterialModel time
"""
function bact_timestep!(bacterialModel)
    bacterialModel.timestep += 1
end

"""
bact_exposed
Bacterial colonies for exposed animals
"""
function bact_exposed!(bacterialModel, colony)
    #bacterialModel.clinical != true && return
    colony.processed == true && return
    bacterialModel.total_status ∉ [3,4] && return
    
    if bacterialModel.days_exposed == 1 
        #3 = exposed pathogenic
        #4 = exposed resistant
        colony.id % 10 != 0 && return
        if bacterialModel.total_status == 3 
                    colony.status = 1
                    colony.processed = true
        elseif bacterialModel.total_status == 4
                    colony.status = 2
                    colony.processed = true
        end
    elseif bacterialModel.days_exposed > 1
        for neighbour in colony.neighbours
                rand(bacterialModel.rng) < 0.5 && continue
                colony.status ∉ [1,2] && continue
                competing_neighbour = neighbour
                competing_neighbour[1] < 1  && continue
                competing_neighbour[1] > 33 && continue
                competing_neighbour[2] < 1 && continue
                competing_neighbour[2] > 33 && continue
                competing_neighbour = bacterialModel.colonies[competing_neighbour]
                
                competing_neighbour.status != 0 && continue
                colony.fitness < competing_neighbour.fitness && continue
                rand(bacterialModel.rng) < 0.5 && continue
                    competing_neighbour.status = colony.status
                    competing_neighbour.processed = true
        end
    end
end

function bact_subclinical!(bacterialModel, colony)
    bacterialModel.clinical == true && return
    colony.processed == true && return
    bacterialModel.total_status ∉ [3,4] && return
    
    if bacterialModel.days_exposed == 1 
        #3 = exposed pathogenic
        #4 = exposed resistant
        colony.id % 10 != 0 && return
        if bacterialModel.total_status == 3 
                    colony.status = 1
                    colony.processed = true
        elseif bacterialModel.total_status == 4
                    colony.status = 2
                    colony.processed = true
        end
    elseif bacterialModel.days_exposed > 1
        for neighbour in colony.neighbours
                rand(bacterialModel.rng) < 0.25 && continue
                colony.status ∉ [1,2] && continue
                competing_neighbour = neighbour
                competing_neighbour[1] < 1  && continue
                competing_neighbour[1] > 33 && continue
                competing_neighbour[2] < 1 && continue
                competing_neighbour[2] > 33 && continue
                competing_neighbour = bacterialModel.colonies[competing_neighbour]
                
                competing_neighbour.status != 0 && continue
                colony.fitness < competing_neighbour.fitness && continue
                rand(bacterialModel.rng) < 0.5 && continue
                    competing_neighbour.status = colony.status
                    competing_neighbour.processed = true
        end
    end
end

"""
bact_recovery!(bacterialModel)
Immune response to pathogenic bacteria
"""
function bact_recovery!(bacterialModel, colony)
    colony.processed == true && return
    bacterialModel.days_recovered == 0 && return
    colony.status ∉ [1,2] && return
    rand(bacterialModel.rng)  > ℯ^(-bacterialModel.days_recovered) && return
    colony.status = 0
    colony.processed = true
end

"""
bact_step!
Update attributes over time
"""
function bact_step!(bacterialModel)

  bact_processed!.(bacterialModel.colonies)

    bact_exposed!.(Ref(bacterialModel), bacterialModel.colonies)
    #bact_subclinical!.(Ref(bacterialModel), bacterialModel.colonies)
    bact_recovery!.(Ref(bacterialModel), bacterialModel.colonies)
    bact_treatment!.(Ref(bacterialModel), bacterialModel.colonies)
    bact_repopulate!.(Ref(bacterialModel), bacterialModel.colonies)
    bact_carrier!.(Ref(bacterialModel), bacterialModel.colonies, rand(10:100))
    bact_fitness!.(Ref(bacterialModel), bacterialModel.colonies)
  
    bacterialModel.pop_r = 0
    bacterialModel.pop_s = 0
    bacterialModel.pop_p = 0
    bacterialModel.pop_d = 0
   
    count_colonies!.(Ref(bacterialModel), bacterialModel.colonies)#Update the population

    
    total_pop = bacterialModel.pop_r + bacterialModel.pop_s + bacterialModel.pop_p

    bacterialModel.pop_p = bacterialModel.pop_p/total_pop
    bacterialModel.pop_r = bacterialModel.pop_r/total_pop
    bacterialModel.pop_s = bacterialModel.pop_s/total_pop



end

    

