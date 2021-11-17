
include("bacteria_na.jl")

#Define agent ============================

using Random: MersenneTwister
using Distributions: Rayleigh, truncated
using CSV, DataFrames

#= """
Agent type - AnimalAgent
""" =#
 mutable struct AnimalAgent
    id::Int16
    pos::CartesianIndex{3}
    status::Int8
    stage::Int8
    days_infected::Int8
    days_exposed::Int8
    days_carrier::Int8
    days_recovered::Int16
    days_treated::Int8
    treatment::Int8
    pop_p::Float32
    pop_d::Float32
    pop_r::Float32
    bacteriaSubmodel::BacterialModel
    dic::Int16
    dim::Int16
    stress::Bool
    sex::Int8
    calving_season::Int8
    age::Int16
    lactation::Int8
    pregstat::Int8
    trade_status::Int8
    neighbours::Array{CartesianIndex}
end


"""
AnimalModel
Type container for animal model
"""
 mutable struct AnimalModel
    farmno::Int16
    animals::Array{AnimalAgent}
    timestep::Int16
    rng::MersenneTwister
    system::Int8
    psc::Int16
    psc_2::Int16
    psc_3::Int16
    psc_4::Int16
    msd::Int16
    msd_2::Int16
    msd_3::Int16
    msd_4::Int16
    seed::Int8
    mortality::Float32
    farm_status::Int8
    optimal_size::Int16
    treatment_prob::Float32
    treatment_length::Int8
    carrier_prob::Float32
    number_stock::Int16
    num_lactating::Int16
    current_lactating::Int16
    optimal_lactating::Int16
    current_heifers::Int16
    optimal_heifers::Int16
    tradeable_stock::Int16
    sending::Array{AnimalAgent}
    receiving::Array{AnimalAgent}
    density_lactating::Int8
    density_calves::Int8
    density_dry::Int8
    positions::LinearIndices
    pop_r::Int16
    pop_s::Int16
    pop_p::Int16
    pop_d::Int16
    num_calves::Int16
    num_weaned::Int16
    num_dh::Int16
    num_heifers::Int16
    num_dry::Int16
end


"""
AnimalData
Struct for animal data 
"""
mutable struct AnimalData
    id::Array{Int8}
    timestep::Array{Int16}
    pop_r::Array{Int16}
    pop_s::Array{Int16}
    pop_p::Array{Int16}
    pop_d::Array{Int16}
    num_calves::Array{Int16}
    num_weaned::Array{Int16}
    num_dh::Array{Int16}
    num_heifers::Array{Int16}
    num_lactating::Array{Int16}
    num_dry::Array{Int16}
end

#Initialise the data struct

 animalData = AnimalData([0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0])

"""
count_animals!(animalModel)
Count stock classes and types at each step of the animalModel
"""
function count_animals!(animalModel)

    #Reset the counts from the last step
    animalModel.pop_r = 0
    animalModel.pop_s = 0
    animalModel.pop_p = 0
    animalModel.pop_d = 0
    animalModel.num_calves = 0
    animalModel.num_weaned = 0
    animalModel.num_dh = 0
    animalModel.num_heifers = 0
    animalModel.num_lactating = 0
    animalModel.num_dry = 0
    animalModel.number_stock = 0

    #Count the values of each agent type, and update
@async Threads.@threads for animal in animalModel.positions
        if isassigned(animalModel.animals, animalModel.positions[animal])
            if animalModel.animals[animal].status == 0
                animalModel.pop_s += 1
            elseif animalModel.animals[animal].status == 1
                animalModel.pop_p += 1
            elseif animalModel.animals[animal].status == 2
                animalModel.pop_r += 1
            elseif animalModel.animals[animal].status == 10
                animalModel.pop_d += 1
            elseif animalModel.animals[animal].stage == 0
                animalModel.num_calves += 1
            elseif animalModel.animals[animal].stage == 1
                animalModel.num_weaned += 1
            elseif animalModel.animals[animal].stage == 2
                animalModel.num_dh += 1
            elseif animalModel.animals[animal].stage == 3
                animalModel.num_heifers += 1
            elseif animalModel.animals[animal].stage == 4
                animalModel.num_lactating += 1
            elseif animalModel.animals[animal].stage == 5
                animalModel.num_dry += 1
            end   
        end
    end

    animalModel.number_stock = animalModel.num_calves + animalModel.num_dh + animalModel.num_heifers + animalModel.num_lactating + animalModel.num_dry
end

"""
initial_status!(herd_prev)
Set the initial status of farms based on the herd-level prevalence
"""
function initial_status!(animalModel, id)
    if animalModel.farm_status == 0#No active infection, no resistance
        if id % 30 == 0
            5#Carrier pathogenic
        else
            0
        end
    elseif animalModel.farm_status == 1#Pathogenic infected
        if id % 25 == 0
            1#Pathogenic
        elseif id % 30 == 0
            5#Carrier pathogenic
        else
            0#susceptible
        end
    elseif animalModel.farm_status == 2#Resistant infected
        if id % 25 == 0
            2#Resistant
        elseif id % 30 == 0
            6#Carrier resistant
        elseif id % 40 == 0
            5#Carrier pathogenic
        else
            0#susceptible
        end
    end
end

"""
get_neighbours_animal!(pos)
Return the position of neighbouring animals on the same plane in a 3 dimensional matrix
#Choose a random agent to interact with
"""
function get_neighbours_animal(pos)

    surrounding = Array{CartesianIndex}(undef, 8)    

    surrounding[1] = pos + CartesianIndex(-1,1,0)
    surrounding[2] = pos + CartesianIndex(0,1,0)
    surrounding[3] = pos + CartesianIndex(1,1,0)
    surrounding[4] = pos + CartesianIndex(1,0,0)
    surrounding[5] = pos + CartesianIndex(1,-1,0)
    surrounding[6] = pos + CartesianIndex(0,-1,0)
    surrounding[7] = pos + CartesianIndex(-1,-1,0)
    surrounding[8] = pos + CartesianIndex(-1,0,0)


    return surrounding

end

function initialiseSpring(;
    farmno::Int8 = FarmAgent.id,
    farm_status::Int8,
    system::Int8,
    psc::Int16,
    msd::Int16,
    seed::Int8,
    mortality::Float32,
    optimal_size::Int16,
    num_lactating::Int16,
    treatment_prob::Float32,
    treatment_length::Int8,
    carrier_prob::Float32,
    timestep::Int16,
    density_lactating::Int8,
    density_dry::Int8,
    density_calves::Int8,
    )

    #Agent space =======================================================
    animals = Array{AnimalAgent}(undef, 100,100,10)

    #Create the initial model parameters ===============================

    psc_2 = 0
    psc_3 = 0
    psc_4 = 0
    msd_2 = 0
    msd_3 = 0
    msd_4 = 0
    number_stock = 0
    current_lactating = 0
    optimal_lactating = 0
    current_heifers = 0
    optimal_heifers = 0
    tradeable_stock = 0
    sending = Array{AnimalAgent}(undef, 15)
    receiving =  Array{AnimalAgent}(undef, 15)
    rng = MersenneTwister(seed)
    pop_r = 0
    pop_s = 0
    pop_p = 0
    pop_d = 0
    num_calves = 0
    num_weaned = 0
    num_dh = 0
    num_heifers = 0
    num_dry = 0
    number_stock = 0



    positions = LinearIndices(animals)

    #Set up the model ====================================================

    animalModel = AnimalModel(farmno, animals, timestep, rng, system, psc, psc_2, psc_3, psc_4, msd, msd_2, msd_3, msd_4, seed, mortality, farm_status, optimal_size, treatment_prob, treatment_length, carrier_prob, number_stock, num_lactating, current_lactating, optimal_lactating, current_heifers, optimal_heifers, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, num_calves, num_weaned, num_dh, num_heifers, num_dry)

    
    # Set the initial stock parameters
    num_heifers = floor(0.3*num_lactating)
    num_weaned = floor(0.3*num_lactating)

    # Add the lactating cows ---------------------------------------------
    id_counter = 0
    for cow in 1:(num_lactating - num_heifers)
        id_counter += 1
        id = Int16(id_counter)
        stage = Int8(5)
        pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_lactating*√num_lactating)), 2)..., 5)
        while isassigned(animals, LinearIndices(animals)[pos[1], pos[2], pos[3]]) == true
            pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_lactating*√num_lactating)), 2)..., 5)
        end
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int8(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = Int8(0)
        pop_p = Float32(0.0)
        pop_d = Float32(0.0)
        pop_r = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic =  Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 290)))) #Gives a 63% ICR for this rng
        dim = Int16(0)
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int16(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
        lactation= round(age/365) - 1
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours)    
        animals[pos] = animal
    end

# Add the heifers ---------------------------------------------

    for heifer in 1:num_heifers
        id_counter += 1
        id = Int16(id_counter)
        stage = 4
        pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 5)
        while isassigned(animals, LinearIndices(animals)[pos[1], pos[2], pos[3]]) == true
            pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 5)
        end
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int8(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = Int8(0)
        pop_p = Float32(0.0)
        pop_d = Float32(0.0)
        pop_r = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic =  Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 290)))) #Gives a 63% ICR for this rng
        dim = 0
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int16(floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))) # Defined using initial age function
        lactation= round(age/365) - 1
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours)    
        animals[pos] = animal     
    end

     #Add weaned animals

     for heifer in 1:num_weaned
        id_counter += 1
        id = Int16(id_counter)
        stage = 4
        pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 2)
        while isassigned(animals, LinearIndices(animals)[pos[1], pos[2], pos[3]]) == true
            pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 2)
        end
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int8(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = Int8(0)
        pop_p = Float32(0.0)
        pop_d = Float32(0.0)
        pop_r = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic =  Int16(0) #Gives a 63% ICR for this rng
        dim = 0
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int16(floor(rand(truncated(Rayleigh(365),(295), (385))))) # Defined using initial age function
        lactation= round(age/365) - 1
        pregstat = 0#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours)    
        animals[pos] = animal     
    end


    animalModel.animals = animals

    count_animals!(animalModel)

    return animalModel
    

end

@time animalModel = initialiseSpring(farmno = Int8(1), farm_status = Int8(2), system = Int8(0), psc = Int16(0), msd = Int16(0), seed = Int8(42), mortality = Float32(0.05), optimal_size = Int16(100), num_lactating = Int16(100), treatment_prob = Float32(0.5), treatment_length = Int8(5), carrier_prob = Float32(0.5), timestep = Int16(0), density_lactating = Int8(6), density_calves = Int8(3), density_dry = Int8(7))

"""
update_animal!(animalModel)
Increment animal parameters
"""
function update_animal!(animalModel, position)
    #Advance age
    animalModel.animals[position].age += 1
    #Advance days treated if treated
    if animalModel.animals[position].treatment == 1
        animalModel.animals[position].days_treated += 1
    end
    #Advance bacterial model timestep
    animalModel.animals[position].bacteriaSubmodel.timestep += 1
end


"""
run_submodel!(animalModel)
Run the bacterial submodel for each animalModel
"""
function run_submodel!(animalModel, position)
        if animalModel.animals[position].status != 0 && animalModel.animals[position].status != 10
            bact_step!(animalModel.animals[position].bacteriaSubmodel, bacterialData)
        end
end

"""
new_animal_position!(animalModel, density)
"""
function new_animal_position!(animalModel; density, number_stock, new_stage, new_status, position)
    
    newpos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(density*√number_stock)), 2)..., new_stage)
    
    while isassigned(animalModel.animals, LinearIndices(animalModel.animals)[newpos[1], newpos[2], newpos[3]]) == true
        newpos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(density*√number_stock)), 2)..., new_stage)
    end

    animalModel.animals[position].stage = new_status
    animalModel.animals[position].stage = new_stage
    animalModel.animals[position].pos = newpos
    animalModel.animals[newpos] = animalModel.animals[position]
    animalModel.animals[position] = undef

end
"""
animal_mortality!(animalModel. position)
Determine animal mortality if infected
"""
function animal_mortality!(animalModel, position)

    if animalModel.animals[position].status == 2#resistant
        if animalModel.animals[position].stage == 0#Calf
            if rand(animalModel.rng) < rand(animalModel.rng, 0.05:0.01:0.3)#Has a chance of dying of between 5 and 30%
                new_animal_position!(animalModel, density = 1, number_stock = 10000, new_stage = 10, new_status = 10, position = position)
            end    
        end
    end

end


"""
animal_step!
Animal stepping function
"""
function animal_step!(animalModel, animalData)
    @async Threads.@threads for position in animalModel.positions
        if isassigned(animalModel.animals, animalModel.positions[position])
            update_animal!(animalModel, position)
            animal_mortality!(animalModel, position)
            run_submodel!(animalModel, position)    
        end
    end

    count_animals!(animalModel)
    animal_export!(animalModel,animalData)

end


"""
animal_export!(animalModel, animalData)
"""
function animal_export!(animalModel,animalData)
    push!(animalData.id, animalModel.farmno)
    push!(animalData.timestep, animalModel.timestep)
    push!(animalData.pop_r, animalModel.pop_r)
    push!(animalData.pop_d, animalModel.pop_d)
    push!(animalData.num_calves, animalModel.num_calves)
    push!(animalData.num_weaned, animalModel.num_weaned)
    push!(animalData.num_dh, animalModel.num_dh)
    push!(animalData.num_heifers, animalModel.num_heifers)
    push!(animalData.num_lactating, animalModel.num_lactating)
    push!(animalData.num_dry, animalModel.num_dry)
end

"""
export_bacterialData!(bacterialData)
Create DataFrame from bacterial data, write to CSV
"""
function export_bacterialData!(bacterialData)
    #Create the data frame
    dat = DataFrame(
        id = bacterialData.id,
        timestep = bacterialData.timestep,
        pop_r = bacterialData.pop_r,
        pop_s = bacterialData.pop_s,
        pop_p = bacterialData.pop_p,
        pop_d = bacterialData.pop_d
    )
    #Write the results to CSV
    CSV.write("./export/bact_na.csv", dat)

end

"""
export_bacterialData!(bacterialData)
Create DataFrame from bacterial data, write to CSV
"""
function export_animalData!(bacterialData)
    #Create the data frame
    dat = DataFrame(
        id = animalData.id,
        step = animalData.timestep,
        pop_r = animalData.pop_r,
        pop_d = animalData.pop_d,
        num_calves = animalData.num_calves,
        num_weaned = animalData.num_weaned,
        num_dh = animalData.num_dh,
        num_heifers = animalData.num_heifers,
        num_lactating = animalData.num_lactating,
        num_dry = animalData.num_dry
    )
    #Write the results to CSV
    CSV.write("./export/animal_na.csv", dat)

end



@time animal_step!(animalModel, animalData)

#ProfileView.@profview animal_step!(animalModel)

@time [animal_step!(animalModel, animalData) for i in 1:365]

export_animalData!(animalData)