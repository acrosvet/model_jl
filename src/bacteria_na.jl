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
    processed::Bool
end

"""
Container for model
"""
mutable struct BacterialModel
    id::Int16
    timestep::Int16
    pop_r::Float16
    pop_s::Float16
    pop_p::Float16
    pop_d::Float16
    nbact::Int16
    colonies::Array{BacterialAgent}
    total_status::Int8
    days_treated::Int8
    days_exposed::Int8
    days_recovered::Int16
    days_carrier::Int16
    stress::Bool
    seed::Int8
    rng::MersenneTwister
end

# Container for data

mutable struct BacterialData
    id::Array{Int16}
    timestep::Array{Int16}
    pop_r::Array{Float16}
    pop_s::Array{Float16}
    pop_p::Array{Float16}
    pop_d::Array{Float16}
end

bacterialData = BacterialData([0],[0],[0.0],[0.0],[0.0],[0.0])
#Utility ====================================================================================
"""
count_colonies!
Count the number of each type of bacterial colony in an animal host
"""
function count_colonies!(bacterialModel)


    pop_r = 0.0
    pop_s = 0.0
    pop_p = 0.0
    pop_d = 0.0

    for colony in 1:length(bacterialModel.colonies)
        if bacterialModel.colonies[colony].status == 0
            pop_s += 1
        elseif bacterialModel.colonies[colony].status == 1
            pop_p += 1
        elseif  bacterialModel.colonies[colony].status == 2
            pop_r += 1
        elseif bacterialModel.colonies[colony].status == 10
            pop_d += 1
        end
    end
    

    total_pop = pop_p + pop_s + pop_r

    bacterialModel.pop_p = pop_p/total_pop
    bacterialModel.pop_r = pop_r/total_pop
    bacterialModel.pop_s = pop_s/total_pop
    bacterialModel.pop_d = pop_d


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
    days_carrier = 0


    id = animalno


    #Set up the model
   bacterialModel = BacterialModel(id, timestep, pop_r, pop_s, pop_p, pop_d, nbact, colonies, total_status, days_treated, days_exposed, days_recovered, days_carrier, stress, seed, rng)
     
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
            fitness = rand(bacterialModel.rng, 0.98:0.001:0.99)
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
    
        count_colonies!(bacterialModel)
    

return bacterialModel

end

@time bacterialModel =  initialiseBacteria(animalno = Int16(100), nbact = Int16(33*33), total_status = Int8(2), days_treated = Int8(0), days_exposed = Int8(0), days_recovered = Int8(0), stress = false, seed = Int8(42))


"""
bact_treatment!
Bacteria respond to treatment
"""
function bact_treatment!(bacterialModel, colony)

    bacterialModel.days_treated == 0 && return


   # for colony in 1:length(bacterialModel.colonies)
        if bacterialModel.colonies[colony].status ≤ 1 #For susceptible and sensitive
            if rand(bacterialModel.rng)  < ℯ^(-bacterialModel.days_treated/20)
                if rand(bacterialModel.rng) < 0.5
                    bacterialModel.colonies[colony].status = 10#10 is dead
                    bacterialModel.colonies[colony].fitness = 0
                    bacterialModel.colonies[colony].processed = true
                end
            end    
        end
   # end
    
end


"""
bact_repopulate!
Repopulate after treatment
"""
function bact_repopulate!(bacterialModel, colony)

    bacterialModel.pop_d == 0 && return

  #  for i in 1:length(bacterialModel.colonies)
        if bacterialModel.colonies[colony].status == 10
            bacterialModel.colonies[colony].processed == true && return
            competing_neighbour = bacterialModel.colonies[colony].neighbours[rand(bacterialModel.rng,1:8)]
            if (competing_neighbour[1] > 0 && competing_neighbour[2] > 0) && (competing_neighbour[1] ≤ 33 && competing_neighbour[2] ≤ 33)
                if bacterialModel.days_treated != 0 && bacterialModel.total_status ≤ 1
                    if rand(bacterialModel.rng) < 0.5
                        if bacterialModel.colonies[competing_neighbour].status == 1
                            return
                        elseif bacterialModel.colonies[competing_neighbour].status == 0
                            return
                        elseif bacterialModel.colonies[competing_neighbour].status == 2
                            bacterialModel.colonies[colony].status = 2
                            bacterialModel.colonies[colony].processed = true

                        end
                    end
                elseif bacterialModel.days_treated == 0 && bacterialModel.total_status ≤ 1
                    if rand(bacterialModel.rng) < 0.5
                        bacterialModel.colonies[colony].status = bacterialModel.colonies[competing_neighbour].status
                        bacterialModel.colonies[colony].processed = true
                    end
                end
            end    
        end
   # end
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
function bact_carrier!(bacterialModel, colony)

    bacterialModel.total_status != 5 && bacterialModel.total_status != 6 && return

    if bacterialModel.total_status == 6 && bacterialModel.days_carrier == 1#carrier resistant
    #     for colony in 1:bacterialModel.colonies
            if bacterialModel.colonies[colony].id % 10 == 0
                bacterialModel.colonies[colony].processed == true && return
                bacterialModel.colonies[colony].id = 2
                bacterialModel.colonies[colony].processed = true
            end
      #  end
    elseif bacterialModel.total_status == 5 && bacterialModel.days_carrier == 1     
      #   for colony in 1:bacterialModel.colonies
            if bacterialModel.colonies[colony].id % 10 == 0
                bacterialModel.colonies[colony].processed == true && return
                bacterialModel.colonies[colony].id = 1
                bacterialModel.colonies[colony].processed = true
            end
      #  end
    end
end

"""
bact_fitness!
Competition between bacterial colonies
"""
function bact_fitness!(bacterialModel, colony)
  #  for i in 1:length(bacterialModel.colonies)
        bacterialModel.colonies[colony].processed == true && return
            competing_neighbour = bacterialModel.colonies[colony].neighbours[rand(bacterialModel.rng,1:8)]
            if (competing_neighbour[1] > 0 && competing_neighbour[2] > 0) && (competing_neighbour[1] ≤ 33 && competing_neighbour[2] ≤ 33)
                if bacterialModel.colonies[colony].fitness < bacterialModel.colonies[competing_neighbour].fitness
                    if rand(bacterialModel.rng) < 0.5
                        bacterialModel.colonies[colony].status = bacterialModel.colonies[competing_neighbour].status
                        bacterialModel.colonies[colony].fitness = bacterialModel.colonies[competing_neighbour].fitness
                    end
                end
            end    
  #  end
end

"""
bact_processed
ensure bacteria do not get processed twice
"""
function bact_processed!(bacterialModel, colony)
    #for colony in 1:length(bacterialModel.colonies)
        bacterialModel.colonies[colony].processed = false
    #end
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

    bacterialModel.total_status != 3 && bacterialModel.total_status != 4 && return
    if bacterialModel.days_exposed == 1 
        #3 = exposed pathogenic
        #4 = exposed resistant

        if bacterialModel.total_status == 3
           # for colony in 1:length(bacterialModel.colonies)
                if bacterialModel.colonies[colony].id % 3 == 0
                    bacterialModel.colonies[colony].status = 1
                    #bacterialModel.colonies[colony].fitness = 1
                    bacterialModel.colonies[colony].processed = true
              #  end
            end
        elseif bacterialModel.total_status == 4
           # for colony in 1:length(bacterialModel.colonies)
                if bacterialModel.colonies[colony].id % 3 == 0
                    bacterialModel.colonies[colony].status = 2
                    #bacterialModel.colonies[colony].fitness = 1
                    bacterialModel.colonies[colony].processed = true
            #    end
            end
        end
    elseif bacterialModel.days_exposed > 1
       # for i in 1:length(bacterialModel.colonies)
            bacterialModel.colonies[colony].processed == true && return
                competing_neighbour = bacterialModel.colonies[colony].neighbours[rand(bacterialModel.rng,1:8)]
                if (competing_neighbour[1] > 0 && competing_neighbour[2] > 0) && (competing_neighbour[1] ≤ 33 && competing_neighbour[2] ≤ 33)
                    if bacterialModel.colonies[colony].status == 1 || bacterialModel.colonies[colony].status == 2
                        #if rand(bacterialModel.rng) > 0.5
                            bacterialModel.colonies[competing_neighbour].status = bacterialModel.colonies[colony].status
                            bacterialModel.colonies[competing_neighbour].processed = true
                        #end
                    end
                end     
       # end
    end
end

"""
bact_recovery!(bacterialModel)
Immune response to pathogenic bacteria
"""
function bact_recovery!(bacterialModel, colony)
    bacterialModel.days_recovered == 0 && return

   # for colony in 1:length(bacterialModel.colonies)
        bacterialModel.colonies[colony].status == 5 || bacterialModel.colonies[colony] == 6
        if rand(bacterialModel.rng)  < ℯ^(-bacterialModel.days_recovered/20)
            if rand(bacterialModel.rng) < 0.5
                bacterialModel.colonies[colony].status = 0#0 is susceptible
                bacterialModel.colonies[colony].processed = true
            end
        end  
 #   end

end
"""
bact_step!
Update attributes over time
"""
function bact_step!(bacterialModel, bacterialData)
    @async Threads.@threads for colony in 1:length(bacterialModel.colonies)
        bact_processed!(bacterialModel, colony)#Reset the processed counter
        bact_exposed!(bacterialModel, colony)
        bact_recovery!(bacterialModel, colony)#Recovery over time
        bact_treatment!(bacterialModel, colony) #Apply treatment
        bact_repopulate!(bacterialModel, colony)#Replace bacteria killed by treatment
        bact_carrier!(bacterialModel, colony)#Set carrier status
        bact_fitness!(bacterialModel, colony)
    end
    count_colonies!(bacterialModel)#Update the population
    bact_export!(bacterialModel, bacterialData)#Export the bacterial data
    bact_timestep!(bacterialModel)#Step through time
end
    


bacterialModel.total_status = 0
bacterialModel.days_exposed = 0
bacterialModel.days_recovered = 0

 @time bact_step!(bacterialModel, bacterialData)


[bact_step!(bacterialModel, bacterialData) for i in 1:365]

#@time [bact_step!(bacterialModel, bacterialData) for i in 1:10]
