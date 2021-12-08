

  include("./bacteria_na.jl")
  using Dates
  using JLD

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
    days_exposed::Int
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
    fpt::Bool
    vaccinated::Bool
    susceptibility::Float32
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
    vacc_rate::Float32
    fpt_rate::Float32
    prev_r::Float32
    prev_p::Float32
    prev_cr::Float32
    prev_cp::Float32
end


"""
AnimalData
Struct for animal data 
"""

  mutable struct AnimalData
    id::Array{Int8}
    timestep::Array{Date}
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


  mutable struct AllData
    id::Array{Int}
    date::Array{Date}
    stage::Array{Int}
    pregstat::Array{Int}
    status::Array{Int}
    dic::Array{Int}
    dim::Array{Int}
    age::Array{Int}
    pop_p::Array{Float32}
    pop_d::Array{Float32}
    pop_r::Array{Float32}
    submodel_r::Array{Float32}
    submodel_d::Array{Float32}
    submodel_p::Array{Float32}
    days_infected::Array{Int8}
    days_exposed::Array{Int}
    days_recovered::Array{Int16}
    days_carrier::Array{Int16}
    days_treated::Array{Int16}
    treatment::Array{Bool}
end

  allData = AllData([], [], [], [], [], [], [], [], [],[],[],[],[],[],[],[],[],[],[],[])
#Initialise the data struct

   animalData = AnimalData([0], [Date(0)], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0])

"""
count_animals!(animalModel)
Count stock classes and types at each step of the animalModel
"""

  function count_animals!(animalModel)


    #Stages 
    animalModel.current_calves = count(i->(i.stage == 1), animalModel.animals)
    animalModel.current_weaned = count(i->(i.stage == 2), animalModel.animals)
    animalModel.current_dh = count(i->(i.stage == 4), animalModel.animals)
    animalModel.current_heifers = count(i->(i.stage == 3), animalModel.animals)
    animalModel.current_lactating = count(i->(i.stage == 5), animalModel.animals)
    animalModel.current_dry = Int16(count(i->(i.stage == 6), animalModel.animals))

    #assigned_statuses
    animalModel.pop_p = Int16(count(i->(i.status == 1), animalModel.animals))
    animalModel.pop_r = count(i->(i.status == 2), animalModel.animals)
    animalModel.pop_s = count(i->(i.status == 0), animalModel.animals)
    animalModel.pop_d = count(i->(i.status == 10), animalModel.animals)
    


    animalModel.current_stock = animalModel.current_weaned + animalModel.current_calves + animalModel.current_dh + animalModel.current_heifers + animalModel.current_lactating + animalModel.current_dry 
end

"""
initial_status!(herd_prev)
Set the initial status of farms based on the herd-level prevalence
"""

function initial_status!(animalModel)
  bernoulli = rand(animalModel.rng)

  if bernoulli < animalModel.prev_p
    1
  elseif bernoulli < animalModel.prev_r
    2
  elseif bernoulli < animalModel.prev_cp
    5
  elseif bernoulli < animalModel.prev_cr
    6
  else
    0
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
    date::Date,
    vacc_rate::Float32,
    fpt_rate::Float32,
    prev_r::Float32,
    prev_p::Float32,
    prev_cr::Float32,
    prev_cp::Float32
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

    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter, vacc_rate, fpt_rate, prev_r, prev_p, prev_cr, prev_cp)
    
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
        status = Int8(initial_status!(animalModel))
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int8(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_d = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        dic =  Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
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
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  0.2 : 0.5
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility)    
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
        status = Int8(initial_status!(animalModel))
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int8(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
        days_recovered = Int8(0)
        days_treated = Int8(0)
        treatment = false
        pop_p = Float32(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        pop_p = Float32(bacteriaSubmodel.pop_p)
        pop_r = Float32(bacteriaSubmodel.pop_r)
        dic =  Int16(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
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
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  0.2 : 0.5
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility)    
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
        status = Int8(initial_status!(animalModel))
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int8(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
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
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  0.2 : 0.5
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility)    
        push!(animalModel.animals, animal)
    end

    count_animals!(animalModel)


    return animalModel


end


"""
update_animal!(animalModel)
Increment animal parameters
"""

  function update_animal!(animalModel, animal)
    if animal.dim > 0 
        animal.dim += 1 
    end 

    if animal.dic > 0 
        animal.dic += 1
    end

    if animal.days_infected > 0
        animal.days_infected += 1
    end 
    
    if animal.days_treated > 0
        animal.days_treated += 1
    end

    if animal.days_carrier > 0
        animal.days_carrier += 1
    end

    if animal.days_exposed > 0
        animal.days_exposed += 1
    end

    if animal.days_recovered > 0
      animal.days_recovered += 1
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
    bacteriaSubmodel.total_status = animal.status
    bacteriaSubmodel.days_treated = animal.days_treated
    bacteriaSubmodel.days_exposed = animal.days_exposed
    bacteriaSubmodel.days_recovered = animal.days_recovered
    #bacteriaSubmodel.stress = animal.stress

    
        animal.status == 0 && return

        if animal.status == 5 && animal.days_carrier == 1
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif animal.status == 6 && animal.days_carrier == 1 
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif animal.status == 7 && animal.days_recovered < 10
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif animal.status == 8 && animal.days_recovered < 10
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif animal.status == 1 || animal.status == 2
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif (animal.status == 3 || animal.status == 4)
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        elseif (animal.status == 5 || animal.status ==6) && animal.stress == true
          bact_step!(animal.bacteriaSubmodel, bacterialData)
        end
        

        animal.pop_r = bacteriaSubmodel.pop_r
        animal.pop_p = bacteriaSubmodel.pop_p
end


"""
animal_mortality!(animalModel. position)
Determine animal mortality if infected
"""

  function animal_mortality!(animalModel, animal)
    if animal.status == 1 || animal.status == 2
    animal.stage == 0 && return
    if animal.stage == 1 && rand(animalModel.rng) < rand(animalModel.rng, 0.01:0.05)
      cull!(animal, animalModel)
    elseif rand(animalModel.rng) < rand(animalModel.rng, 0.0001:0.001)
      cull!(animal, animalModel)
    end
    
   # println("Mortality")
    end
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
  if animal.status == 1 || animal.status == 2
    animal.days_infected == 0 && return
    if animal.days_infected >= rand(animalModel.rng, 5:7)
      if rand(animalModel.rng) > animalModel.carrier_prob
            if animal.status == 1
              animal.days_infected = 0
              animal.days_recovered = 1
              animal.bacteriaSubmodel.days_recovered = 1
              animal.status = animal.bacteriaSubmodel.total_status =  7
              println("recovered r")
              println(animal.status)
            elseif animal.status == 2
              animal.days_infected = 0
              animal.days_recovered = 1
              animal.bacteriaSubmodel.days_recovered = 1
              animal.status = animal.bacteriaSubmodel.total_status = 8
              println("recovered p")
              println(animal.status)
            end
      else 
          if animal.status == 2
            animal.days_infected = 0
            animal.days_recovered = 1
            animal.bacteriaSubmodel.days_recovered = 1
            animal.status = animal.bacteriaSubmodel.total_status = 6
            println("carrier r")
            println(animal.status)
          elseif animal.status == 1
            animal.days_infected = 0
            animal.days_recovered = 1
            animal.bacteriaSubmodel.days_recovered = 1
            animal.status = animal.bacteriaSubmodel.total_status =  5
            println("carrier p")
            println(animal.status)
          end
      end
    end
    end

#=     animal.days_infected == 0 && return
    animal.status != 1 && animal.status != 2 && return
    recovery_time = 5
    animal.days_infected == recovery_time && return 
    animal.days_infected = 0
    if  animalModel.carrier_prob > rand(animalModel.rng)
        animal.bacteriaSubmodel.days_carrier = animal.days_carrier = 1
        animal.status == 1 ? animal.status = 5 : animal.status = 6
    else
        animal.status ==  1 ? animal.status = 7 : animal.status = 8
        animal.bacteriaSubmodel.days_recovered = animal.days_recovered = 1
    end =#
end

"""
animal_transmission!(animal)
Transmit infection between animals.
Only infected, recovering or carrier animals can transmit to their neighbours
"""
function animal_transmission!(animal, animalModel)
    if animal.status == 1 || animal.status == 2 || animal.status == 5 || animal.status == 6
      #animal.days_recovered > 5 && return
      pos = animal.pos
      animal.neighbours = get_neighbours_animal(pos)
      # bernoulli < 0.5 && return
      animal.status == 1 && rand(animalModel.rng) > animalModel.pop_p && return
      animal.status == 2 && rand(animalModel.rng) > animalModel.pop_r && return
      #The animal can now go on to infect its neighbours
      for i in 1:length(animal.neighbours)
          competing_neighbour = filter(x -> x.pos == animal.neighbours[i], animalModel.animals)
          #println(competing_neighbour)
          isempty(competing_neighbour) == true && continue
          competing_neighbour = competing_neighbour[1]
         # push!(competing_neighbour, empty_vec)
          if competing_neighbour.status == 0 || competing_neighbour.status == 7 || competing_neighbour.status == 8
              #rand(animalModel.rng) < 0.5 && continue
              if rand(animalModel.rng) < competing_neighbour.susceptibility
                animal.status % 2 == 0 ? competing_neighbour.status = 4 : competing_neighbour.status = 3
                competing_neighbour.days_exposed = 1
                competing_neighbour.bacteriaSubmodel.days_exposed = 1
                println("transmission")
                println(competing_neighbour.status)
                println(competing_neighbour.id)
              end
          end
      end
    end
end

"""
animal_shedding!(animal)
Recrudescent infection from carrier animals
"""
function animal_shedding!(animal)
    rand(animalModel.rng) < 0.5 && return
    if (animal.status == 5 || animal.status == 6) && animal.stress == true
    #animal.status != 5 || animal.status != 6 && return
      if animal.status == 5
        animal.bacteriaSubmodel.days_exposed = 1
        animal.bacteriaSubmodel.total_status = 3
      elseif animal.status == 6
        animal.bacteriaSubmodel.days_exposed = 1
        animal.bacteriaSubmodel.total_status = 4
      end
    elseif (animal.status == 5 || animal.status == 6) && animal.stress == false
      if animal.status == 5
        animal.bacteriaSubmodel.days_exposed = 0
        animal.bacteriaSubmodel.total_status = 5
        animal.bacteriaSubmodel.days_carrier = 1
      elseif animal.status == 6
        animal.bacteriaSubmodel.days_exposed = 0
        animal.bacteriaSubmodel.total_status = 6
        animal.bacteriaSubmodel.days_carrier = 1
      end
    end
  end

"""
animal_susceptiblility(animal, animalModel)
Animals return to susceptibility at a variable interval after recovery, simulates waning immunity
"""

  function animal_susceptiblility!(animal, animalModel)
    #animal.days_recovered = 0 && return
    if animal.status == 7 || animal.status == 8
#=       if animal.days_recovered >= rand(animalModel.rng, 60:120)
        animal.days_recovered = 0
        animal.days_exposed = 0
        animal.bacteriaSubmodel.days_exposed = 0
        animal.status = 0 #Return to susceptible
        animal.susceptibility = animal.vaccinated == true ?  rand(animalModel.rng, 0.5:0.01:1) : 1.0
      end =#
      animal.susceptibility = ℯ^(-500/animal.days_recovered)
    end
end

"""
animal_treatment!(animal, animalModel)
Decide to treat animals
"""

  function animal_treatment!(animal, animalModel)
    animal.treatment == true && return
    if animal.status == 1 || animal.status == 2 
      bernoulli = rand(animalModel.rng)
      bernoulli > animalModel.treatment_prob && return
      animal.days_treated = 1
      animal.treatment = true
      animal.bacteriaSubmodel.days_treated = 1
      #println("treatment")
    end
end

"""
animal_fpt_vacc(animal)
Adapt animal susceptibility based on vaccination status
"""
function animal_fpt_vacc!(animal, animalModel)
  if animal.fpt == true && animal.age < 60
    animal.susceptibility = rand(animalModel.rng, 0.75:0.01:1.0)
  end

  if animal.age == 60 && rand(animalModel.rng) < animalModel.vacc_rate
    animal.vaccinated = true
    animal.susceptibility = 0.2
  end

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
    animal.bacteriaSubmodel.days_treated = 0
end

"""
getloc(animalModel, pos)
"""
function getloc(animalModel,pos)
  for i in 1:length(animalModel.positions)
    if animalModel.positions[i] == pos
      return i
    end
  end
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
    ind = getloc(animalModel, oldpos)
    ind === nothing && return
    deleteat!(animalModel.positions,ind)

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
    move_animal!(animal, animalModel, 4, animalModel.density_dry, animalModel.current_dh)
end

"""
move_heifer!(animal, animalModel)
Move heifer
"""

  function move_heifer!(animal, animalModel)
    move_animal!(animal, animalModel, 3, animalModel.density_dry, animalModel.current_heifers)
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
    #animal.status == 0 && return
    if animal.stage == 1
        move_calf!(animal, animalModel)
    elseif animal.stage == 2
        move_weaned!(animal, animalModel)
    elseif animal.stage == 4
        move_dh!(animal, animalModel)
    elseif animal.stage == 3
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

    if animal.stage == 1
        animalModel.current_calves -= 1
    elseif animal.stage == 2
        animalModel.current_weaned -=1
    elseif animal.stage == 3
        animalModel.current_heifers -=1 
    elseif animal.stage == 4
        animalModel.current_dh -= 1 
    elseif animal.stage == 5
        animalModel.current_lactating -=1 
    elseif animal.stage == 6
        animalModel.current_dry -= 1
    end

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
    animal.age ≤ Int(floor(rand(animalModel.rng, truncated(Rayleigh(7*365), 5*365, 7*365)))) && return
    cull!(animal, animalModel)
    #println("age culled")
end

"""
fertility_cull!(animal, animalModel)
cull for fertility
"""

  function fertility_cull!(animal, animalModel)
    animal.dim < 280 && return
    animal.dic ≥ 150 && return
    cull!(animal, animalModel)
   # println("fert cull")
end

"""
do_culls!(animal, animalModel, system)
Perform both cull types
"""

  function do_culls!(animal, animalModel)
    age_cull!(animal, animalModel)
    fertility_cull!(animal, animalModel)
end

"""
cull_seasonal(animal, animalModel)
Cull for seasonal systems (system = 1)
"""

  function cull_seasonal!(animal, animalModel)
    animalModel.system != 1 && return
    animal.stage != 5 && return
    animalModel.current_lactating <= animalModel.optimal_lactating && return
    do_culls!(animal, animalModel)
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
        do_culls!(animal, animalModel)
    elseif animalModel.current_autumn > animalModel.optimal_autumn
        animalModel.calving_season != 2 && return
        do_culls!(animal, animalModel)
    end
end

"""
calving!(animal, animalModel)
Calve cows, create calf.
"""

  function calving!(animal, animalModel)
    #animal.stage != 6 && animal.stage != 4 && return
    #animal.dic < 273 && return
    animal.dic != 283  && return
        animal.pregstat = 0
        animal.dic = 0
        animal.stage = 5
        animal.dim = 1
        animal.lactation += 1
        animal.carryover = false
        #println("calved")
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

        seed = animalModel.seed
        bacteriaSubmodel = initialiseBacteria(animalno = Int16(id), nbact = Int16(33*33), total_status = Int8(status), days_treated = Int8(days_treated), days_exposed = Int8(days_exposed), days_recovered = Int8(days_recovered), stress = false, seed = Int8(seed))
        pop_p = bacteriaSubmodel.pop_p
        pop_d = bacteriaSubmodel.pop_d
        pop_r = bacteriaSubmodel.pop_r
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
        fpt = rand(animalModel.rng) < animalModel.fpt_rate ? true : false
        vaccinated = animal.vaccinated
        susceptibility = fpt == true ? rand(animalModel.rng, 0.75:0.01: 1.0) : animal.susceptibility
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility)    
        push!(animalModel.animals, animal)
       # println("birth")
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
    if animalModel.date == (animalModel.msd + Month(3))
        if rand(animalModel.rng) < 0.85
            animal.pregstat = 1
            animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 93))))
        end
    end
#=     animalModel.date != (animalModel.msd + Month(3)) && return
    rand(animalModel.rng) > 0.85 && return
        animal.pregstat = 1
        animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 93))))
        #println("cow joined") =#
end

"""
animal_joining!(animal, animalModel)
"""

  function animal_joining!(animal, animalModel)
    animal.pregstat != 0 && return
    animal.stage != 5 && return
    if animalModel.system == 1
        join_seasonal!(animal, animalModel)
        #println("joining")
    elseif animalModel.system == 2
       # join_split!(animal, animalModel)
    else
       # join_batch!(animal, animalModel)
    end

end

"""
animal_status!(animal)
Update the status of each animal depending on its bacterial population.
"""

  function animal_status!(animal)
     if animal.status == 3 || animal.status == 4
    if animal.pop_r ≥ 0.5
        animal.status = 2 
        animal.days_infected = 1
        animal.days_exposed = 0
    elseif animal.pop_p ≥ 0.5
        animal.status = 1
        animal.days_infected = 1
        animal.days_exposed = 0
    end

    if animal.status == 1 || animal.status == 2
      if animal.pop_r ≥ 0.5
        animal.status = 2
      elseif animal.pop_p ≥ 0.5
        animal.status = 1
      end
    end
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
    animal.age <= rand(animalModel.rng, 55:65) && return
    if rand(animalModel.rng) < 0.5 && animalModel.current_weaned < rand(animalModel.rng, 0.95:0.1:1.1)*animalModel.optimal_weaned
        animal.stage = 2
        move_animal!(animal, animalModel, 2, animalModel.density_dry, animalModel.current_weaned)
    else 
        cull!(animal, animalModel)
        #("calf cull")
    end
end

"""
animal_heifer!(animal, animalModel)
Transition to the heifer lifestage
"""

  function animal_heifer!(animal, animalModel)  
    animal.age <= 13*30*rand(animalModel.rng, 0.9:0.01:1.1)  && return
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
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(42), 1, 63))))
    move_animal!(animal, animalModel, 4, animalModel.density_dry, animalModel.current_dh)
end

"""
join_heifer_seasonal!(animal, animalModel)
Join heifers for seasonal systems 
"""

  function join_heifer_seasonal!(animal, animalModel)
    animalModel.system != 1 && return
    if animalModel.date == (animalModel.msd + Day(42))
        heifer_pregnancy!(animal, animalModel)
    end
    #println("Heifer joined")
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
    #println("Dried off")
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
    animal.dim != 305 && return
    #animal.dim <= rand(animalModel.rng, 290:315) && return
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
animal_stress!(animal,animalModel)
"""
function animal_stress!(animal, animalModel)
    if animal.dic >= 223 || animal.dim < 21 || (animal.age <= 2.5*365 && animal.stage == 5)
      animal.stress = true
      animal.susceptibility = rand(animalModel.rng, 0.5:0.01:1.0)
    else
      animal.stress = false
      animal.susceptibility = animal.vaccinated == true ? 0.2 : 0.5
    end
  end

"""
animal_step!
Animal stepping function
"""

  function animal_step!(animalModel, animalData)


    for x in 1:length(animalModel.animals)
         checkbounds(Bool, animalModel.animals, x) == false && continue   
            # !isassigned(animalModel.animals, animalModel.animals[position]) && continue
         #x > length(animalModel.animals) && continue
         animal = animalModel.animals[x]
         #Disease dynamics
            animal_fpt_vacc!(animal, animalModel)
            animal_stress!(animal, animalModel)
            animal_mortality!(animalModel, animal)
            animal_recovery!(animal, animalModel)
            animal_transmission!(animal, animalModel)
            animal_shedding!(animal)
            animal_susceptiblility!(animal, animalModel)
            animal_treatment!(animal, animalModel)
            end_treatment!(animal, animalModel)
            run_submodel!(animal)
            animal_status!(animal)


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
            animal_shuffle!(animal, animalModel)
            get_neighbours_animal(animal.pos)
            update_animal!(animalModel, animal)

            export_alldata!(animal, animalModel, allData)

     
    end

    #Step global model vars
    animal_mstep!(animalModel, animalData)

end



"""
animal_export!(animalModel, animalData)
"""

  function animal_export!(animalModel,animalData)
    push!(animalData.id, animalModel.farmno)
    push!(animalData.timestep, animalModel.date)
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

  function export_alldata!(animal, animalModel, allData)
    push!(allData.id, animal.id)
    push!(allData.date, animalModel.date)
    push!(allData.stage, animal.stage)
    push!(allData.pregstat, animal.pregstat)
    push!(allData.status, animal.status)
    push!(allData.dic, animal.dic)
    push!(allData.dim, animal.dim)
    push!(allData.age, animal.age)
    push!(allData.pop_p, animal.pop_p)
    push!(allData.pop_d, animal.pop_d)
    push!(allData.pop_r, animal.pop_r)
    push!(allData.submodel_r, animal.bacteriaSubmodel.pop_r)
    push!(allData.submodel_d, animal.bacteriaSubmodel.pop_d)
    push!(allData.submodel_p, animal.bacteriaSubmodel.pop_p)
    push!(allData.days_infected, animal.days_infected)
    push!(allData.days_exposed, animal.days_exposed)
    push!(allData.days_recovered, animal.days_recovered)
    push!(allData.days_treated, animal.days_treated)
    push!(allData.treatment, animal.treatment)





    
end

  function write_allData!(allData)
    dat = DataFrame(
        id = allData.id,
        date = allData.date,
        stage = allData.stage,
        pregstat = allData.pregstat,
        status = allData.status,
        dic = allData.dic,
        dim = allData.dim,
        age = allData.age,
        pop_p = allData.pop_p,
        pop_d = allData.pop_d,
        pop_r = allData.pop_r,
        submodel_r = allData.submodel_r,
        submodel_d = allData.submodel_d,
        submodel_p = allData.submodel_p,
        days_infected = allData.days_infected,
        days_exposed = allData.days_exposed,
        days_recovered = allData.days_recovered,
        days_treated = allData.days_treated,
        treatment = allData.treatment
    )

    CSV.write("./export/all_na.csv", dat)
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


# Run the model -------------------------------------------------


@time   animalModel = initialiseSpring(
                farmno = Int8(1),
                farm_status = Int8(2),
                system = Int8(1),
                msd = Date(2021,9,24),
                seed = Int8(42),
                optimal_stock = Int16(273),
                optimal_lactating = Int16(273),
                treatment_prob = Float32(0),
                treatment_length = Int8(3),
                carrier_prob = Float32(0.01),
                timestep = Int16(0),
                density_lactating = Int8(6),
                density_dry = Int8(7),
                density_calves = Int8(3),
                date = Date(2021,7,2),
                vacc_rate = Float32(0.7),
                fpt_rate = Float32(0.0),
                prev_r = Float32(0.01),
                prev_p = Float32(0.01),
                prev_cr = Float32(0.08),
                prev_cp = Float32(0.02)
);


