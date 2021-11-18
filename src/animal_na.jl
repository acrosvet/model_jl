
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
    treatment::Bool
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
    processed::Bool
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
    id_counter::Int16
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
            elseif animalModel.animals[animal].stage == 1
                animalModel.num_calves += 1
            elseif animalModel.animals[animal].stage == 2
                animalModel.num_weaned += 1
            elseif animalModel.animals[animal].stage == 3
                animalModel.num_dh += 1
            elseif animalModel.animals[animal].stage == 4
                animalModel.num_heifers += 1
            elseif animalModel.animals[animal].stage == 5
                animalModel.num_lactating += 1
            elseif animalModel.animals[animal].stage == 6
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
    processed = false
    )

    #Agent space =======================================================
    animals = Array{AnimalAgent}(undef, 100,100,8)

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
    id_counter = 0



    positions = LinearIndices(animals)

    #Set up the model ====================================================

    animalModel = AnimalModel(farmno, animals, timestep, rng, system, psc, psc_2, psc_3, psc_4, msd, msd_2, msd_3, msd_4, seed, mortality, farm_status, optimal_size, treatment_prob, treatment_length, carrier_prob, number_stock, num_lactating, current_lactating, optimal_lactating, current_heifers, optimal_heifers, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, num_calves, num_weaned, num_dh, num_heifers, num_dry, id_counter)

    
    # Set the initial stock parameters
    num_heifers = floor(0.3*num_lactating)
    num_weaned = floor(0.3*num_lactating)

    # Add the lactating cows ---------------------------------------------
    #Lactating stage is 5, lactating index is 5
    animalModel.id_counter = 0
    for cow in 1:(num_lactating - num_heifers)
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
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
        treatment = false
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
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed)    
        animals[pos] = animal
    end

# Add the heifers ---------------------------------------------

    for heifer in 1:num_heifers
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = 4
        pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 4)
        while isassigned(animals, LinearIndices(animals)[pos[1], pos[2], pos[3]]) == true
            pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√num_heifers)), 2)..., 4)
        end
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int8(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
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
        lactation= 0
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed)    
        animals[pos] = animal     
    end

     #Add weaned animals

     for weaned in 1:num_weaned
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = 2
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
        treatment = false
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
        lactation= 0
        pregstat = 0#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed)    
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
function update_animal!(animalModel, animal)
    animal.bacteriaSubmodel.timestep += 1
    #Advance age
    animal.age += 1
    #Advance days treated if treated
    animal.treatment != 1 && return
    animal.days_treated += 1
end


"""
run_submodel!(animalModel)
Run the bacterial submodel for each animalModel
"""
function run_submodel!(animal)
        animal.status == 0 && return
        animal.status == 10 && return
        bact_step!(animal.bacteriaSubmodel, bacterialData)
end

"""
new_animal_position!(animalModel, density)
"""
function new_animal_position!(animalModel, animal; density, number_stock, new_stage, new_status, position)
    
    newpos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(density*√number_stock)), 2)..., new_stage)
    
    while isassigned(animalModel.animals, LinearIndices(animalModel.animals)[newpos[1], newpos[2], newpos[3]]) == true
        newpos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(density*√number_stock)), 2)..., new_stage)
    end

    animal.stage = new_stage
    animal.status = new_status
    animal.pos = new_pos

    animalModel.animals[newpos] = animalModel.animals[position]
    animalModel.animals[position] = undef

end
"""
animal_mortality!(animalModel. position)
Determine animal mortality if infected
"""
function animal_mortality!(animalModel, animal)
    animal.status != 2 && animal.status != 1 && return
    animal.stage != 0 && return
    rand(animalModel.rng) > rand(animalModel.rng, 0.05:0.01:0.3) && return
    cull!(animalModel, animal)
end

"""
animal_processed!(animalModel, position)
Reset the animal processed flag
"""
function animal_processed!(animal)
    animal.processed = false
end


"""
check_assignment
Determine if a position of interest is defined or not
"""
function check_assignment(space, pos)
    isassigned(space, LinearIndices(space)[pos[1], pos[2], pos[3]])
end
"""
animal_recovery!(animal)
Animals recover from infection
"""
function animal_recovery!(animal, animalModel)
    animal.days_infected == 0 && return
    animal.status != 1 && animal.status != 2 && return
    recovery_time = rand(animalModel.rng, 5:7)
    animal.days_infected < recovery_time && return 
    animal.days_infected = 0
    bernoulli = rand(animalModel.rng)
    if  bernoulli > animalModel.carrier_prob
        animal.days_carrier = 1
        animal.status == 1 ? animal.status = 7 : animal.status = 8
    else
        animal.status ==  1 ? animal.status = 5 : animal.status = 6
        animal.days_recovered = 1
    end
end

"""
animal_transmission!(animal)
Transmit infection between animals.
Only infected, recovering or carrier animals can transmit to their neighbours
"""
function animal_transmission!(animal, animalModel)
    animal.status == 0 || animal.status > 8 && return
    pos = animal.pos
    animal.neighbours = get_neighbours_animal(pos)
    bernoulli = rand(animalModel.rng)
    if animal.status % 2 == 0 #Resistant animals are even, sensitive animals are odd
        bernoulli > animal.pop_r && return
    else
        bernoulli > animal.pop_p && return
    end 
    #The animal can now go on to infect its neighbours
    @async Threads.@threads for coord in enumerate(animal.neighbours)
        checkbounds(Bool, animalModel.animals, coord) == false && continue
        check_assignment(animalModel.animals, coord) == false && continue
        competing_neighbour = animalModel.animals[coord]
        competing_neighbour.status != 0  || competing_neighbour.status > 8 && continue
        competing_neighbour.status = animal.status
    end
end

"""
animal_shedding!(animal)
Recrudescent infection from carrier animals
"""
function animal_shedding!(animal)
    animal.stress == false && return
    animal.status != 5 && animal.status != 6 && return
    animal.days_exposed = 1
    animal.status == 5 ? animal.status = 3 : animal.status = 4 #If carriers are stressed, they shed as though exposed again
end

"""
animal_susceptiblility(animal, animalModel)
Animals return to susceptibility at a variable interval after recovery, simulates waning immunity
"""
function animal_susceptiblility!(animal, animalModel)
    animal.days_recovered != 0 && return
    animal.status != 7 && animal.status != 8 && return
    animal.days_recovered < rand(animalModel.rng, 60:180) && return
    animal.days_exposed = 1
    animal.status == 7 ? animal.status = 3 : animal.status = 4 #Return to exposed pathogenic or exposed resistant
end

"""
animal_treatment!(animal, animalModel)
Decide to treat animals
"""
function animal_treatment!(animal, animalModel)
    animal.treatment == true && return
    animal.status != 1 && animal.status != 2 && return
    bernoulli = rand(animalModel.rng)
    bernoulli > animalModel.treatment_prob && return
    animal.days_treated = 1
    animal.treatment = true
end

"""
end_treatment!(animal, animalModel)
End treatment after course duration.
"""
function end_treatment!(animal, animalModel)
    animal.treatment == false && return
    animal.days_treated < animalModel.treatment_length && return
    animal.treatment = false
    animal.days_treated = 0
end

"""move_animal(animal, animalModel)
Shuffle animals at each step
"""
function move_animal!(animal, animalModel, stage, density, stock_in_class)
    stock_in_class == 0 ? range = 10 : range = Int(floor(density*√stock_in_class))
    range > 100 ? range = 100 : range = range
    oldpos = animal.pos
    newpos = CartesianIndex(rand(animalModel.rng, 1:range)...,stage)
    while check_assignment(animalModel.animals, newpos) == true
        newpos = CartesianIndex(rand(animalModel.rng, 1:range)...,stage)
    end
    animalModel.animals[newpos] = animal
    animalModel.animals[oldpos] = undef
end

"""
move_calf!(animal, animalModel)
Move Calves
"""
function move_calf!(animal, animalModel)
    move_animal!(animal, animalModel, 1, animalModel.density_calves, animalModel.num_calves)
end

"""
move_weaned!(animal, animalModel)
Move weaned
"""
function move_weaned!(animal, animalModel)
    move_animal!(animal, animalModel, 2, animalModel.density_dry, animalModel.num_weaned)
end

"""
move_dh!(animal, animalModel)
Move dh
"""
function move_dh!(animal, animalModel)
    move_animal!(animal, animalModel, 3, animalModel.density_dry, animalModel.num_dh)
end

"""
move_heifer!(animal, animalModel)
Move heifer
"""
function move_heifer!(animal, animalModel)
    move_animal!(animal, animalModel, 4, animalModel.density_dry, animalModel.num_heifers)
end

"""
move_lactating!(animal, animalModel)
Move lactating
"""
function move_lactating!(animal, animalModel)
    move_animal!(animal, animalModel, 5, animalModel.density_lactating, animalModel.num_lactating)
end

"""
move_dry!(animal, animalModel)
Move dry
"""
function move_dry!(animal, animalModel)
    move_animal!(animal, animalModel, 6, animalModel.density_dry, animalModel.num_dry)
end




"""
animal_shuffle!(animal, animalModel)
Randomly move animals.
"""
function animal_shuffle!(animal, animalModel)
    animal.stage > 6 && return
    if animal.stage == 1
        move_calf!(animal, animalModel)
    elseif animal.stage == 2
        move_weaned!(animal, animalModel)
    elseif animal.stage == 3
        move_dh!(animal, animalModel)
    elseif animal.stage == 4
        move_heifer(animal, animalModel)
    elseif animal.stage == 5
        move_lactating!(animal, animalModel)
    elseif animal.stage == 6
        move_dry!(animal, animalModel)
    end
end

"""
cull!(animal, animalModel)
Move an animal to level 10, culled
"""
function cull!(animal, animalModel)
    move_animal!(animal, animalModel, 8, 1, 10000)
    animal.stage = 8
    animal.status = 10
end

"""
cull_empty_dry!(animal, animalModel)
"""
function cull_empty_dry!(animal, animalModel)
    animal.stage != 6 && return
    animal.pregstat != 0 && return
    cull!(animal, animalModel)
end

"""
cull_slipped!(animal, animalModel)
cull animals more than 320 dic that have not calved
"""
function cull_slipped!(animal, animalModel)
    animal.dic < 320 && return
    cull!(animal, animalModel)

end

"""
age_cull!(animal)
"""
function age_cull!(animal, animalModel)
    animal.age ≤ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 2*365, 7*365)))) && return
    cull!(animal, animalModel)
end

"""
fertility_cull!(animal, animalModel)
cull for fertility
"""
function fertility_cull!(animal, animalModel)
    animal.dim < 280 && return
    animal.dic ≥ 150 && return
    cull!(animal, animalModel)
end

"""
do_culls!(animal, animalModel, system)
Perform both cull types
"""
function do_culls!(animal, animalModel, system)
    age_cull!(animal, animalModel)
    fertility_cull!(animal, animalModel)
    animalModel.status == 10 ?  system -= 1 : return
end

"""
cull_seasonal(animal, animalModel)
Cull for seasonal systems (system = 0)
"""
function cull_seasonal!(animal, animalModel)
    animalModel.system != 0 && return
    animal.stage != 5 && return
    animalModel.current_lac < animalModel.num_lac && return
    do_culls!(animal, animalModel, animalModel.current_lac)
end

"""
cull_split!(animal, animalModel)
Cull for split systems (system 1)
"""
function cull_split!(animal, animalModel)
    animalModel.system != 2 && return
    animal.stage!= 5 && return
    if animalModel.current_spring > animalModel.num_spring
        animal.calving_season != 1 && return
        do_culls!(animal, animalModel, animalModel.current_spring)
    elseif animalModel.current_autumn > animalModel.num_autumn
        animalModel.calving_season != 2 && return
        do_culls!(animal, animalModel, animalModel.current_autumn)
    end
end

"""
calving!(animal, animalModel)
Calve cows, create calf.
"""
function calving!(animal, animalModel)
    animal.stage != 6 && animal.stage != 4 && return
    animal.dic < 273 && return
    animal.dic != 283 + rand(animalModel.rng, -10:1:10) && return
        animal.pregstat = 0
        animal.dic = 0
        animal.stage = 5
        animal.dim = 1
        animal.lactation += 1
        animal_birth!(animal, animalModel)
        move_animal!(animal, animalModel, 5, animalModel.density_lactating, animalMode.current_lactating)
end

"""
animal_birth!(animal,animalModel)
Create a calf
"""
function animal_birth!(animal, animalModel)
        id = Int16(1)
        stage = 1
        pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_calves*√animalModel.current_calves)), 2)..., 1)
        while isassigned(animalModel.animals, LinearIndices(animalModel.animals)[pos[1], pos[2], pos[3]]) == true
            pos = CartesianIndex(rand(animalModel.rng, 1:Int(floor(animalModel.density_calves*√animalModel.current_calves)), 2)..., 1)
        end
        status = (animal.status == 1 || animal.status == 2) ? (animal.status == 1  ? 3 : 4) : 0
        days_infected = 0
        days_exposed = (status == 3 || status == 4) ? Int8(1) : Int8(0)
        days_carrier = Int8(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_p = animal.pop_p
        pop_d = animal.pop_d
        pop_r = animal.pop_r
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic = 0
        dim = 0
        stress = false
        sex = rand(animalModel.rng) > 0.5 ? 1 : 0
        calving_season = animal.calving_season
        age = Int16(1)
        lactation = 0
        pregstat = 0
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed)    
        animalModel.animals[pos] = animal
end


"""
bobby_cull!(animal, animalModel)
Cull bobby calves
"""
function bobby_cull!(animal, animalModel)
    animal.stage != 0 && return
    animal.sex != 0 && return
    animal.age < 4 && return
    cull!(animal, animalModel)
end

"""
join_seasonal!(animal, animalModel)
Join animals in seasonal systems
"""
function join_seasonal!(animal, animalModel)
    animalModel.timestep != animalModel.msd + 120 && return
    rand(animalModel.rng) > 0.85 && return
        animal.pregstat = 1
        animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
        animal.joined = true
end

"""
animal_joining!(animal, animalModel)
"""
function animal_joining!(animal, animalModel)
    animalModel.pregstat == 0 && return
    animalModel.stage != 4 && return
    if animalModel.system == 1
        join_seasonal!(animal, animalModel)
    elseif animalModel.system == 2
        join_split!(animal, animalModel)
    else
        join_batch!(animal, animalModel)
    end

end

"""
animal_step!
Animal stepping function
"""
function animal_step!(animalModel, animalData)
    @async Threads.@threads for position in animalModel.positions
         animal = animalModel.animals[position]
         !isassigned(animalModel.animals, animal) && continue
         animal.stage > 5 && continue #Actions do not apply to levels 6 and above
         #Disease dynamics
            update_animal!(animalModel, animal)
            animal_mortality!(animalModel, animal, position)
            animal_recovery!(animal, animalModel)
            animal_transmission!(animal, animalModel)
            animal_shedding!(animal)
            animal_susceptiblility!(animal, animalModel)
            animal_treatment!(animal, animalModel)
            end_treatment!(animal, animalModel)
            run_submodel!(animal)
        #Population dynamics
            cull_slipped!(animal, animalModel)
            cull_empty_dry!(animal, animalModel)
            cull_seasonal!(animal, animalModel)
    end

    #Move the agents in space
    @async Threads.@threads for position in animalModel.positions
        animal = animalModel.animals[position]
         !isassigned(animalModel.animals, animal) && continue
         animal.stage > 5 && continue 
         animal_shuffle!(animal, animalModel)
    end

    #refresh the positions
    animalModel.positions = LinearIndices(animalModel.animals)

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

@time [animal_step!(animalModel, animalData) for i in 1:1825]

@time export_animalData!(animalData)