
include("bacteria_na.jl")
using Dates

#Define agent ============================

using Random: MersenneTwister
using Distributions: Rayleigh, truncated
using CSV, DataFrames

"""
Agent type - AnimalAgent
"""
 mutable struct AnimalAgent
    id::Int16
    pos::Array{Int8}
    status::Int8
    stage::Int8
    days_infected::Int8
    days_exposed::Int8
    days_carrier::Int16
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
    neighbours::Array{Array{Int8}}
    processed::Bool
    carryover::Bool
end


"""
AnimalModel
Type container for animal model
"""
 mutable struct AnimalModel
    farmno::Int16
    animals::Array{AnimalAgent}
    timestep::Int16
    date::Date
    rng::MersenneTwister
    system::Int8
    msd::Date
    msd_2::Date
    msd_3::Date
    msd_4::Date
    seed::Int8
    farm_status::Int8
    optimal_stock::Int16
    treatment_prob::Float32
    treatment_length::Int8
    carrier_prob::Float32
    current_stock::Int16
    current_lactating::Int16
    optimal_lactating::Int16
    current_heifers::Int16
    optimal_heifers::Int16
    current_calves::Int16
    optimal_calves::Int16
    current_weaned::Int16
    optimal_weaned::Int16
    current_dh::Int16
    optimal_dh::Int16
    current_dry::Int16
    optimal_dry::Int16
    tradeable_stock::Int16
    sending::Array{AnimalAgent}
    receiving::Array{AnimalAgent}
    density_lactating::Int8
    density_calves::Int8
    density_dry::Int8
    positions::Array{Array{Int8}}
    pop_r::Int16
    pop_s::Int16
    pop_p::Int16
    pop_d::Int16
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
    pop_rec_r::Array{Int16}
    pop_rec_p::Array{Int16}
    pop_car_p::Array{Int16}
    pop_car_r::Array{Int16}
    num_calves::Array{Int16}
    num_weaned::Array{Int16}
    num_dh::Array{Int16}
    num_heifers::Array{Int16}
    num_lactating::Array{Int16}
    num_dry::Array{Int16}
    pop_er::Array{Int16}
    pop_ep::Array{Int16}
end

#Initialise the data struct

 animalData = AnimalData([0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0])

"""
count_animals!(animalModel)
Count stock classes and types at each step of the animalModel
"""
function count_animals!(animalModel)


    #Stages 
    animalModel.current_calves = count(i->(i.stage == 1), animalModel.animals)
    animalModel.current_weaned = count(i->(i.stage == 2), animalModel.animals)
    animalModel.current_dh = count(i->(i.stage == 3), animalModel.animals)
    animalModel.current_heifers = count(i->(i.stage == 4), animalModel.animals)
    animalModel.current_lactating = count(i->(i.stage == 5), animalModel.animals)
    animalModel.current_dry = Int16(count(i->(i.stage == 6), animalModel.animals))

    #assigned_statuses
    animalModel.pop_p = Int16(count(i->(i.status == 1), animalModel.animals))
    animalModel.pop_r = count(i->(i.status == 2), animalModel.animals)
    animalModel.pop_s = count(i->(i.status == 0), animalModel.animals)
    animalModel.pop_d = count(i->(i.status == 10), animalModel.animals)
    


    animalModel.current_stock = animalModel.current_calves + animalModel.current_dh + animalModel.current_heifers + animalModel.current_lactating + animalModel.current_dry 
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
        if id % 10 == 0
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

    surrounding = Array{Array{Int8}}(undef,8)  

    surrounding[1] = pos + [-1,1,0]
    surrounding[2] = pos + [0,1,0]
    surrounding[3] = pos + [1,1,0]
    surrounding[4] = pos + [1,0,0]
    surrounding[5] = pos + [1,-1,0]
    surrounding[6] = pos + [0,-1,0]
    surrounding[7] = pos + [-1,-1,0]
    surrounding[8] = pos + [-1,0,0]


    return surrounding

end

function initialiseSpring(;
    farmno::Int8 = FarmAgent.id,
    farm_status::Int8,
    system::Int8,
    msd::Date,
    seed::Int8,
    optimal_stock::Int16,
    optimal_lactating::Int16,
    treatment_prob::Float32,
    treatment_length::Int8,
    carrier_prob::Float32,
    timestep::Int16,
    density_lactating::Int8,
    density_dry::Int8,
    density_calves::Int8,
    date::Date
    )

    #Agent space =======================================================
    animals = Array{AnimalAgent}[]

    #Create the initial model parameters ===============================
    msd_2 = msd_3 = msd_4 = Date(0)
    current_stock = current_lactating = current_dry = current_heifers = current_dh = current_weaned = current_calves = 0
    optimal_dry = optimal_heifers = optimal_dh = optimal_weaned = optimal_calves = 0
    tradeable_stock = 0
    sending = receiving = Array{AnimalAgent}(undef, 15)
    rng = MersenneTwister(seed)
    pop_p = pop_r = pop_s = pop_d = 0
    id_counter = 0
    positions = Array{Array{Int}}[]
    processed = false

    #Set up the model ====================================================

    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter)
    
    # Set the initial stock parameters
    animalModel.optimal_heifers = animalModel.optimal_weaned = animalModel.optimal_calves = animalModel.optimal_dh = animalModel.optimal_heifers = floor(0.3*animalModel.optimal_lactating)
    

    # Add the dry cows ---------------------------------------------
    #Dry stage is 6, Dry plane is 6. Model opens on day before psc
    animalModel.id_counter = 0
     for cow in 1:(animalModel.optimal_lactating - animalModel.optimal_heifers)
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = Int8(6)
        pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_lactating)), 2)..., stage]
         while pos in animalModel.positions == true
            pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_lactating)), 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int16(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_d = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic =  Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 290)))) #Gives a 63% ICR for this rng
        dim = Int16(0)
        pop_p = Float32(bacteriaSubmodel.pop_p)
        pop_r = Float32(bacteriaSubmodel.pop_r)
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int16(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
        lactation= round(age/365) - 1
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        carryover = false
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover)    
        push!(animalModel.animals, animal)
    end

# Add the heifers ---------------------------------------------
#Heifers about to calve, heifer stage 4
    for heifer in 1:animalModel.optimal_heifers
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = 4
        pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_heifers)), 2)..., stage]
        while pos in animalModel.positions == true
            pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_heifers)), 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int16(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_p = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        pop_p = Float32(bacteriaSubmodel.pop_p)
        pop_r = Float32(bacteriaSubmodel.pop_r)
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
        carryover = false
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover)    
        push!(animalModel.animals, animal)
    end

     #Add weaned animals

    for weaned in 1:animalModel.optimal_weaned
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = 2
        pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_weaned)), 2)..., stage]
        while pos in animalModel.positions == true
            pos = [rand(animalModel.rng, 1:Int(floor(animalModel.density_dry*√animalModel.optimal_weaned)), 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = Int8(initial_status!(animalModel, id))
        days_infected = Int8(0)
        days_exposed = Int8(0)
        days_carrier = Int16(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_p = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        pop_p = Float32(bacteriaSubmodel.pop_p)
        pop_r = Float32(bacteriaSubmodel.pop_r)
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
        carryover = false
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover)    
        push!(animalModel.animals, animal)
    end

    count_animals!(animalModel)


    return animalModel


end

@time animalModel = initialiseSpring(
                farmno = Int8(1),
                farm_status = Int8(2),
                system = Int8(1),
                msd = Date(2021,9,24),
                seed = Int8(42),
                optimal_stock = Int16(100),
                optimal_lactating = Int16(100),
                treatment_prob = Float32(0.5),
                treatment_length = Int8(3),
                carrier_prob = Float32(0.05),
                timestep = Int16(0),
                density_lactating = Int8(5),
                density_dry = Int8(5),
                density_calves = Int8(2),
                date = Date(2021,7,2)
);


"""
update_animal!(animalModel)
Increment animal parameters
"""
function update_animal!(animalModel, animal)
    if animal.dim > 0 
        animal.dim += 1 
    elseif animal.dic > 0 
        animal.dic += 1
    elseif animal.days_infected > 0
        animal.days_infected += 1 
    elseif animal.days_treated > 0
        animal.days_treated += 1
    elseif animal.days_carrier > 0
        animal.days_carrier += 1
    elseif animal.days_exposed > 0
        animal.days_exposed += 1
    end

    animal.bacteriaSubmodel.timestep += 1
    #Advance age
    animal.age += 1

end


"""
run_submodel!(animalModel)
Run the bacterial submodel for each animalModel
"""
function run_submodel!(animal)
    bacteriaSubmodel = animal.bacteriaSubmodel
    #Update the submodel parameters
    bacteriaSubmodel.timestep += 1
    bacteriaSubmodel.total_status = animal.status
    bacteriaSubmodel.days_treated = animal.days_treated
    bacteriaSubmodel.days_exposed = animal.days_exposed
    bacteriaSubmodel.days_recovered = animal.days_recovered
    bacteriaSubmodel.stress = animal.stress
    animal.pop_r = bacteriaSubmodel.pop_r
    animal.pop_p = bacteriaSubmodel.pop_p
    
        animal.status == 0 && return
        animal.status == 10 && return
        bact_step!(animal.bacteriaSubmodel, bacterialData)
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
    println("Mortality")
end

"""
animal_processed!(animalModel, position)
Reset the animal processed flag
"""
function animal_processed!(animal)
    animal.processed = false
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
    animal.status == 0  && return
    pos = animal.pos
    animal.neighbours = get_neighbours_animal(pos)
    bernoulli = rand(animalModel.rng)
    if animal.status % 2 == 0 #Resistant animals are even, sensitive animals are odd
        bernoulli > animal.pop_r && return
    else
        bernoulli > animal.pop_p && return
    end 
    #The animal can now go on to infect its neighbours
    for neighbour in 1:length(animal.neighbours)
        competing_neighbour = filter(x -> animal.pos == neighbour, animalModel.animals)
        isempty(competing_neighbour) == true && continue
        competing_neighbour.status != 0  && continue
        animal.status % 2 == 0 ? competing_neighbour.status = 4 : competing_neighbour.status = 3
        animal.days_exposed = 1
        println("transmission")
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
    animal.days_recovered < rand(animalModel.rng, 60:127) && return
    animal.days_recovered = 0
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
    println("treatment")
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
function move_animal!(animal, animalModel, stage, density,  stock_in_class)
    stock_in_class <= 0 ? range = 10 : range = Int(floor(density*√stock_in_class))
    range > 100 ? range = 100 : range = range
    oldpos = animal.pos
    newpos = [rand(animalModel.rng, 1:range, 2)...,stage]
    while newpos in animalModel.positions == true
        newpos = [rand(animalModel.rng, 1:range, 2)...,stage]
    end
    deleteat!(animalModel.positions, findall(x -> x == oldpos, animalModel.positions))
    animal.pos = newpos
   # animal.neighbours = get_neighbours_animal(animal.pos)
    #splice!(animalModel.positions, oldpos)
    push!(animalModel.positions, newpos)
end

"""
move_calf!(animal, animalModel)
Move Calves
"""
function move_calf!(animal, animalModel)
    move_animal!(animal, animalModel, 1, animalModel.density_calves, animalModel.current_calves)
end

"""
move_weaned!(animal, animalModel)
Move weaned
"""
function move_weaned!(animal, animalModel)
    move_animal!(animal, animalModel, 2, animalModel.density_dry, animalModel.current_weaned)
end

"""
move_dh!(animal, animalModel)
Move dh
"""
function move_dh!(animal, animalModel)
    move_animal!(animal, animalModel, 3, animalModel.density_dry, animalModel.current_dh)
end

"""
move_heifer!(animal, animalModel)
Move heifer
"""
function move_heifer!(animal, animalModel)
    move_animal!(animal, animalModel, 4, animalModel.density_dry, animalModel.current_heifers)
end

"""
move_lactating!(animal, animalModel)
Move lactating
"""
function move_lactating!(animal, animalModel)
    move_animal!(animal, animalModel, 5, animalModel.density_lactating, animalModel.current_lactating)
end

"""
move_dry!(animal, animalModel)
Move dry
"""
function move_dry!(animal, animalModel)
    move_animal!(animal, animalModel, 6, animalModel.density_dry, animalModel.current_dry)
end




"""
animal_shuffle!(animal, animalModel)
Randomly move animals.
"""
function animal_shuffle!(animal, animalModel)
    if animal.stage == 1
        move_calf!(animal, animalModel)
    elseif animal.stage == 2
        move_weaned!(animal, animalModel)
    elseif animal.stage == 3
        move_dh!(animal, animalModel)
    elseif animal.stage == 4
        move_heifer!(animal, animalModel)
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
    deleteat!(animalModel.animals, findall(x -> x == animal, animalModel.animals))
    #splice!(animalModel.animals, animal)
    deleteat!(animalModel.positions, findall(x -> x == animal.pos, animalModel.positions))
    #println("Culled")
end

"""
cull_empty_dry!(animal, animalModel)
"""
function cull_empty_dry!(animal, animalModel)
    animal.stage != 6 && return
    animal.pregstat != 0 && return
    cull!(animal, animalModel)
    animalModel.current_dry -= 1
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
    println("culled")
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
    animalModel.system != 1 && return
    animal.stage != 5 && return
    animalModel.current_lactating < animalModel.optimal_lactating && return
    do_culls!(animal, animalModel, animalModel.current_lactating)
end

"""
cull_split!(animal, animalModel)
Cull for split systems (system 1)
"""
function cull_split!(animal, animalModel)
    animalModel.system != 2 && return
    animal.stage!= 5 && return
    if animalModel.current_spring > animalModel.optimal_spring
        animal.calving_season != 1 && return
        do_culls!(animal, animalModel, animalModel.current_spring)
    elseif animalModel.current_autumn > animalModel.optimal_autumn
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
    animal.dic != 283  && return
        animal.pregstat = 0
        animal.dic = 0
        animal.stage = 5
        animal.dim = 1
        animal.lactation += 1
        animal.carryover = false
        println("calved")
        animal_birth!(animal, animalModel)
        move_animal!(animal, animalModel, 5, animalModel.density_lactating, animalModel.current_lactating)
end

"""
animal_birth!(animal,animalModel)
Create a calf
"""
function animal_birth!(animal, animalModel)
        animalModel.id_counter += 1
        id = Int16(animalModel.id_counter)
        stage = 1
        animalModel.current_calves == 0 ? range = 10 : range = Int(floor(animalModel.density_calves*√animalModel.current_calves))
        range > 100 ? range = 100 : range = range
        pos = [rand(animalModel.rng, 1:range, 2)...,stage]
        while pos in animalModel.positions == true
            pos = [rand(animalModel.rng, 1:range, 2)...,stage]
        end
        push!(animalModel.positions, pos)
        status = (animal.status == 1 || animal.status == 2) ? (animal.status == 1  ? 3 : 4) : 0
        days_infected = 0
        days_exposed = (status == 3 || status == 4) ? Int8(1) : Int8(0)
        days_carrier = Int16(0)
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_p = animal.pop_p
        pop_d = animal.pop_d
        pop_r = animal.pop_r
        seed = animalModel.seed
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
        processed = true
        carryover = false
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover)    
        push!(animalModel.animals, animal)
        println("birth")
end


"""
bobby_cull!(animal, animalModel)
Cull bobby calves
"""
function bobby_cull!(animal, animalModel)
    animal.stage != 1 && return
    animal.sex != 0 && return
    animal.age < 4 && return
    cull!(animal, animalModel)
    animalModel.current_calves -= 1
end

"""
join_seasonal!(animal, animalModel)
Join animals in seasonal systems
"""
function join_seasonal!(animal, animalModel)
    animalModel.date != (animalModel.msd + Month(3)) && return
    rand(animalModel.rng) > 0.85 && return
        animal.pregstat = 1
        animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
        println("cow joined")
end

"""
animal_joining!(animal, animalModel)
"""
function animal_joining!(animal, animalModel)
    animal.pregstat != 0 && return
    animal.stage != 5 && return
    if animalModel.system == 1
        join_seasonal!(animal, animalModel)
        println("joining")
    elseif animalModel.system == 2
        join_split!(animal, animalModel)
    else
        join_batch!(animal, animalModel)
    end

end

"""
animal_status!(animal)
Update the status of each animal depending on its bacterial population.
"""
function animal_status!(animal)
    if animal.pop_r ≥ 0.5
        animal.status = 2 
        animal.days_infected = 1
        animal.days_exposed = 0
    elseif animal.pop_p ≥ 0.5
        animal.status = 1
        animal.days_infected = 1
        animal.days_exposed = 0
    end
#=     animal.pop_p ≥ 0.5 ? (animal.status = 1; animal.days_infected = 1; animal.days_exposed = 0; println("ran")) : animal.status = animal.status
    animal.pop_r ≥ 0.5 ? (animal.status = 2; animal.days_infected = 1; animal.days_exposed = 0) : animal.status = animal.status =#
end

"""
animal_wean!(animal, animalModel)
Wean calves to next lifestage
"""
function animal_wean!(animal, animalModel)
    animal.stage != 1 && return
    animal.age ≤ rand(animalModel.rng, 55:70) && return
    if rand(animalModel.rng) < 0.5
        animal.stage = 2
        move_animal!(animal, animalModel, 2, animalModel.density_dry, animalModel.current_weaned)
    else 
        cull!(animal, animalModel)
        println("calf cull")
    end
end

"""
animal_heifer!(animal, animalModel)
Transition to the heifer lifestage
"""
function animal_heifer!(animal, animalModel)  
    animal.age < 13*30 && return
    animal.stage != 2 && return
    animal.stage = 3
    move_animal!(animal, animalModel, 3, animalModel.density_dry, animalModel.current_heifers)
end

"""
heifer_pregnancy!(animal, animalModel)
Set heifer pregnancy status
"""
function heifer_pregnancy!(animal, animalModel)
    animal.pregstat = 1
    animal.stage = 4
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(50), 0, 63))))
    move_animal!(animal, animalModel, 4, animalModel.density_dry, animalModel.current_dh)
end

"""
join_heifer_seasonal!(animal, animalModel)
Join heifers for seasonal systems 
"""
function join_heifer_seasonal!(animal, animalModel)
    animalModel.system != 1 && return
    animalModel.date != (animalModel.msd + Day(42)) && return
    heifer_pregnancy!(animal, animalModel)
    println("Heifer joined")
end

"""
join_heifer_split!(animal, animalModel)
Join heifers in split systems
"""
function join_heifer_split!(animal, animalModel)
    animalModel.system != 2 && return
    if animal.calving_season == 1 && animalModel.date == (animalModel.msd + Day(42))
        heifer_pregnancy!(animal, animalModel)
    elseif animal.calving_season == 2 && animalModel.date == (animalModel.msd_2 + Day(42))
        heifer_pregnancy!(animal, animalModel)
    end
end

"""
join_heifer_batch!(animal, animalModel)
Join heifers in batch systems
"""
function join_heifer_batch!(animal, animalModel)
    animalModel.system != 3 && return
    if animal.calving_season == 1 && animalModel.date == (animalModel.msd + Day(42))
        heifer_pregnancy!(animal, animalModel)
    elseif animal.calving_season == 2 && animalModel.date == (animalModel.msd_2  - Year(1) + Day(42))
        heifer_pregnancy!(animal, animalModel)
    elseif animal.calving_season == 3 && animalModel.date == (animalModel.msd_3 + Day(42))
        heifer_pregnancy!(animal, animalModel)
    elseif animal.calving_season == 1 && animalModel.date == (animalModel.msd_4 + Day(42))
        heifer_pregnancy!(animal, animalModel)
    end
end

"""
join_heifers!(animal, animalModel)
Join heifers for all systems
"""
function join_heifers!(animal, animalModel)
    animal.pregstat == 1 && return
    animal.stage != 3 && return
    join_heifer_seasonal!(animal, animalModel)
    join_heifer_split!(animal, animalModel)
    join_heifer_batch!(animal, animalModel)
end

"""
cull_empty_heifers!(animal, animalModel)
Cull empty heifers
"""
function cull_empty_heifers!(animal, animalModel)
    animal.stage != 3 && return
    animal.pregstat == 1 && return
    animal.age < 550 && return
    cull!(animal, animalModel)
end


"""
set_dry!(animal, animalModel)
Set an animal's status to dry
"""
function set_dry!(animal, animalModel)
    animal.stage = 6
    animal.dim = 0
    move_animal!(animal, animalModel, 6, animalModel.density_dry, animalModel.current_dry)
end


"""
dryoff_seasonal!(animal, animalModel)
Dry off lactating cows in seasonal systems
"""
function dryoff_seasonal!(animal, animalModel)
    animalModel.system != 1 && return
    set_dry!(animal, animalModel)
    println("Dried off")
end

"""
dryoff_split!(animal, animalModel)
Dry off lactating cows in split systems
"""
function dryoff_split!(animal, animalModel)
    animalModel.system != 2 && return
    if animal.pregstat == 0 && animal.dim < 330 && rand(animalModel.rng) < 0.4 && animal.carryover == false
        animal.calving_season == 1 ? animal.calving_season = 2 : animal.calving_season = 1
        animal.carryover = true
    else
        set_dry!(animal, animalModel)
    end
end

"""
dryoff_batch!(animal, animalModel)
Dryoff animals in batch systems
"""
function dryoff_batch!(animal, animalModel)
    animalModel.system != 3 && return
    if animal.pregstat == 0 && animal.dim < 330 && rand(animalModel.rng) < 0.4 && animal.carryover == false
        animal.carryover = true
        if animal.calving_season < 4
            animal.calving_season += 1
        else
            animal.calving_season = 1
        end 
    else
        set_dry!(animal, animalModel)
    end
end


"""
animal_dryoff!(animal, animalModel)
Dryoff function for all calving systems
"""
function animal_dryoff!(animal, animalModel)
    animal.stage  != 5 && return
    animal.dim < rand(animalModel.rng, 290:315) && return
    dryoff_seasonal!(animal, animalModel)
    dryoff_batch!(animal, animalModel)
    dryoff_split!(animal, animalModel)
end

"""
flag_trades!(animal, animalModel)
Flag animals eligible for trading
"""
function flag_trades!(animal, animalModel)
    animal.stage != 3 && animal.stage != 4 && animal.stage != 5 && animal.stage != 6 && return
    if animal.stage == 3 && animal.age >= 13*30 && animal.age <= 18*30
        animal.trade_status = true
    elseif animal.stage == 6 && animal.dic <= 241
        animal.trade_status = true
    elseif animal.stage == 5 && animal.dim >= 120
        animal.trade_status = true
    else
        animal.trade_status = false
    end
end

"""
update_msd!(animalModel)
Update the msd for each year
"""
function update_msd!(animalModel)
    if Year(animalModel.date) > Year(animalModel.msd)
        animalModel.msd += Year(1)
    elseif animalModel.system == 2 || animalModel.system == 3
        if Year(animalModel.date) > Year(animalModel.msd_2)
            animalModel.msd_2 += Year(1)
        end
    elseif animalModel.system == 3
        if Year(animalModel.date) > Year(animalModel.msd_3)
            animalModel.msd_3 += Year(1)
        elseif Year(animalModel.date) > Year(animalModel.msd_4)
            animalModel.msd_4 += 1
        end
    end
end

"""
animal_mstep!(animal, animalModel)
Update some parameters once per day
"""
function animal_mstep!(animalModel, animalData)
    animalModel.timestep += 1
    animalModel.date += Day(1)
    update_msd!(animalModel)
    count_animals!(animalModel)
    animal_export!(animalModel,animalData)

end


"""
animal_step!
Animal stepping function
"""
function animal_step!(animalModel, animalData)


     for x in 1:length(animalModel.animals)
         checkbounds(Bool, animalModel.animals, x) == false && continue       # !isassigned(animalModel.animals, animalModel.animals[position]) && continue
         animal = animalModel.animals[x]
         animal.stage > 6 && continue #Actions do not apply to levels 6 and above
         #Disease dynamics
            update_animal!(animalModel, animal)
            animal_mortality!(animalModel, animal)
            animal_recovery!(animal, animalModel)
            animal_transmission!(animal, animalModel)
            animal_shedding!(animal)
            animal_susceptiblility!(animal, animalModel)
            animal_treatment!(animal, animalModel)
            end_treatment!(animal, animalModel)
            animal_status!(animal)
            run_submodel!(animal)

        #Population dynamics
            calving!(animal, animalModel)
            bobby_cull!(animal, animalModel)
            animal_wean!(animal, animalModel)
            animal_heifer!(animal, animalModel)

            animal_joining!(animal, animalModel)
            join_heifers!(animal, animalModel)
            cull_empty_heifers!(animal, animalModel)
            cull_slipped!(animal, animalModel)
            animal_dryoff!(animal, animalModel)
            cull_empty_dry!(animal, animalModel)
            cull_seasonal!(animal, animalModel) 
            
        #Trading dynamics
            flag_trades!(animal, animalModel)

        #Movement
            animal.stage > 6 && continue 
            animal_shuffle!(animal, animalModel)
            get_neighbours_animal(animal.pos)
    end

    #Step global model vars
    animal_mstep!(animalModel, animalData)

end



"""
animal_export!(animalModel, animalData)
"""
function animal_export!(animalModel,animalData)
    push!(animalData.id, animalModel.farmno)
    push!(animalData.timestep, animalModel.timestep)
    push!(animalData.pop_r, animalModel.pop_r)
    push!(animalData.pop_d, animalModel.pop_d)
    push!(animalData.pop_p,  count(i->(i.status == 1), animalModel.animals))
    push!(animalData.num_calves, animalModel.current_calves)
    push!(animalData.num_weaned, animalModel.current_weaned)
    push!(animalData.num_dh, animalModel.current_dh)
    push!(animalData.num_heifers, animalModel.current_heifers)
    push!(animalData.num_lactating, animalModel.current_lactating)
    push!(animalData.num_dry, animalModel.current_dry)
    push!(animalData.pop_rec_r,  count(i->(i.status == 8), animalModel.animals))
    push!(animalData.pop_rec_p,  count(i->(i.status == 7), animalModel.animals))
    push!(animalData.pop_car_p,  count(i->(i.status == 5), animalModel.animals))
    push!(animalData.pop_car_r,  count(i->(i.status == 6), animalModel.animals))
    push!(animalData.pop_er,  count(i->(i.status == 4), animalModel.animals))
    push!(animalData.pop_ep,  count(i->(i.status == 3), animalModel.animals))

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
        pop_p = animalData.pop_p,
        num_calves = animalData.num_calves,
        num_weaned = animalData.num_weaned,
        num_dh = animalData.num_dh,
        num_heifers = animalData.num_heifers,
        num_lactating = animalData.num_lactating,
        num_dry = animalData.num_dry,
        pop_rec_r = animalData.pop_rec_r,
        pop_rec_p = animalData.pop_rec_p,
        pop_car_r = animalData.pop_car_r,
        pop_car_p = animalData.pop_car_p,
        pop_er = animalData.pop_er,
        pop_ep = animalData.pop_ep
    )
    #Write the results to CSV
    CSV.write("./export/animal_na.csv", dat)

end



@time animal_step!(animalModel, animalData)

@time [animal_step!(animalModel, animalData) for i in 1:1825]

@time export_animalData!(animalData)