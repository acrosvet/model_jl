

  include("./bacteria_na.jl")
  using Dates
  using JLD2
  using StatsBase
  using Logging


#Define agent ============================

  using Random
  using Distributions: Rayleigh, truncated
  using CSV, DataFrames


"""
Agent type - AnimalAgent
"""

  mutable struct AnimalAgent
    id::Int
    pos::Array{Int}
    status::Int
    stage::Int
    days_infected::Int
    days_exposed::Int
    days_carrier::Int
    days_recovered::Int
    days_treated::Int
    treatment::Bool
    pop_p::Float64
    pop_d::Float64
    pop_r::Float64
    bacteriaSubmodel::BacterialModel
    dic::Int
    dim::Int
    stress::Bool
    sex::Int
    calving_season::Int
    age::Int
    lactation::Int
    pregstat::Int
    trade_status::Int
    neighbours::Array{Array{Int}}
    processed::Bool
    carryover::Bool
    fpt::Bool
    vaccinated::Bool
    susceptibility::Float64
    clinical::Bool
    pen::Int
end

mutable struct Transmissions
  step::Array{Int}
  id::Array{Int}
  stage::Array{Int}
  from::Array{Int}
  to::Array{Int}
  type::Array{Symbol}
end


"""
AnimalData
Struct for animal data 
"""

  mutable struct AnimalData
    id::Array{Int}
    timestep::Array{Date}
    pop_r::Array{Int}
    pop_s::Array{Int}
    pop_p::Array{Int}
    pop_d::Array{Int}
    pop_rec_r::Array{Int}
    pop_rec_p::Array{Int}
    pop_car_p::Array{Int}
    pop_car_r::Array{Int}
    num_calves::Array{Int}
    num_weaned::Array{Int}
    num_dh::Array{Int}
    num_heifers::Array{Int}
    num_lactating::Array{Int}
    num_dry::Array{Int}
    pop_er::Array{Int}
    pop_ep::Array{Int}
    inf_calves::Array{Int}
    inf_heifers::Array{Int}
    inf_weaned::Array{Int}
    inf_dh::Array{Int}
    inf_dry::Array{Int}
    inf_lac::Array{Int}
    inf_pens::Array{Array{Int}}
    clinical::Array{Int}
    subclinical::Array{Int}
    current_b1::Array{Int}
    current_b2::Array{Int}
    current_b3::Array{Int}
    current_b4::Array{Int}
end


"""
AnimalModel
Type container for animal model
"""

  mutable struct AnimalModel
    farmno::Int
    animals::Array{AnimalAgent}
    timestep::Int
    date::Date
    rng::MersenneTwister
    system::Int
    msd::Date
    msd_2::Date
    msd_3::Date
    msd_4::Date
    seed::Int
    farm_status::Int
    optimal_stock::Int
    treatment_prob::Float64
    treatment_length::Int
    carrier_prob::Float64
    current_stock::Int
    current_lactating::Int
    optimal_lactating::Int
    current_heifers::Int
    optimal_heifers::Int
    current_calves::Int
    optimal_calves::Int
    current_weaned::Int
    optimal_weaned::Int
    current_dh::Int
    optimal_dh::Int
    current_dry::Int
    optimal_dry::Int
    tradeable_stock::Int
    sending::Array{AnimalAgent}
    receiving::Array{AnimalAgent}
    density_lactating::Int
    density_calves::Int
    density_dry::Int
    positions::Array{Array{Int}}
    pop_r::Int
    pop_s::Int
    pop_p::Int
    pop_d::Int
    id_counter::Int
    vacc_rate::Float64
    fpt_rate::Float64
    prev_r::Float64
    prev_p::Float64
    prev_cr::Float64
    prev_cp::Float64
    vacc_efficacy::Float64
    current_autumn::Int
    optimal_autumn::Int
    current_spring::Int
    optimal_spring::Int
    current_b1::Int
    current_b2::Int
    current_b3::Int
    current_b4::Int
    optimal_b1::Int
    optimal_b2::Int
    optimal_b3::Int
    optimal_b4::Int
    sim::AnimalData
    contamination::Array{Float64, 3}
    contam_time::Array{Float64, 3}
    contam_type::Array{Float64,3}
    pen_counter::Int
    calf_pen::Int 
    pen_decon::Bool
    transmissions::Transmissions
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
    pop_p::Array{Float64}
    pop_d::Array{Float64}
    pop_r::Array{Float64}
    submodel_r::Array{Float64}
    submodel_d::Array{Float64}
    submodel_p::Array{Float64}
    days_infected::Array{Int}
    days_exposed::Array{Int}
    days_recovered::Array{Int}
    days_carrier::Array{Int}
    days_treated::Array{Int}
    treatment::Array{Bool}
end

  allData = AllData([], [], [], [], [], [], [], [], [],[],[],[],[],[],[],[],[],[],[],[])
#Initialise the data struct


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
    animalModel.current_dry = Int(count(i->(i.stage == 6), animalModel.animals))
    animalModel.current_stock = length(animalModel.animals)


    #assigned_statuses
    animalModel.pop_p = Int(count(i->(i.status == 1 && i.sex == 1), animalModel.animals))
    animalModel.pop_r = count(i->(i.status == 2 && i.sex == 1), animalModel.animals)
    animalModel.pop_s = count(i->(i.status == 0 && i.sex == 1), animalModel.animals)
    animalModel.pop_d = count(i->((i.status == 1 || i.status == 2) && i.sex == 1), animalModel.animals)
    


    animalModel.current_stock = animalModel.current_weaned + animalModel.current_calves + animalModel.current_dh + animalModel.current_heifers + animalModel.current_lactating + animalModel.current_dry 

    #Split systems

    animalModel.current_spring = count(i-> (i.calving_season == 1 && i.stage == 5), animalModel.animals)
    animalModel.current_autumn = count(i-> (i.calving_season == 2 && i.stage == 5), animalModel.animals)
    
    #Batch systems 
    animalModel.current_b1 = count(i-> (i.calving_season == 1 && i.stage == 5), animalModel.animals)
    animalModel.current_b2 = count(i-> (i.calving_season == 2 && i.stage == 5), animalModel.animals)
    animalModel.current_b3 = count(i-> (i.calving_season == 3 && i.stage == 5), animalModel.animals)
    animalModel.current_b4 = count(i-> (i.calving_season == 4 && i.stage == 5), animalModel.animals)
  end

"""
initial_status!(herd_prev)
Set the initial status of farms based on the herd-level prevalence
"""

function initial_status!(animalModel)
  
  if rand() < animalModel.prev_p
    1
  elseif rand() < animalModel.prev_r
    2
  elseif rand() < animalModel.prev_cp
    5
  elseif rand() < animalModel.prev_cr
    6
  else
    0
  end

end

"""
initial_animals!(animalModel; kwargs)
Create a function for generating stock across farm types.
"""
function initial_animals!(animalModel, seed, processed;stockno, stage, dic, dim, age, pregstat, calving_season)
  for cow in 1:stockno
      animalModel.id_counter += 1
      id = Int(animalModel.id_counter)
      pos = [rand(animalModel.rng, 1:Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))), 2)..., stage]
       while pos in animalModel.positions == true
          pos = [rand(animalModel.rng, 1:Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))), 2)..., stage]
      end 
      push!(animalModel.positions, pos)
      status = Int(initial_status!(animalModel))
      days_infected = status == 1 || status == 2 ? 1 : 0
      days_exposed = Int(0)
      days_carrier = status == 5 || status == 6 ? 1 : 0
      days_recovered = Int(0)
      days_treated = Int(0)
      treatment = false
      pop_d = Float64(0.0)
      bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
      pop_p = Float64(bacteriaSubmodel.pop_p)
      pop_r = Float64(bacteriaSubmodel.pop_r)
      stress = false
      sex = 1#Female
      lactation= round(age/365) - 1
      trade_status = 0#false
      neighbours = get_neighbours_animal(pos)
      carryover = false
      fpt = false
      vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
      susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)
      clinical = false
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical)    
      push!(animalModel.animals, animal)
  end
end    


"""
get_neighbours_animal!(pos)
Return the position of neighbouring animals on the same plane in a 3 dimensional matrix
#Choose a random agent to interact with
"""

  function get_neighbours_animal(pos)

    surrounding = Array{Array{Int}}(undef,8)  

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


"""
initialiseSpring
Function for generating system 1 farms (Spring calving)
"""
  function initialiseSpring(;
    farmno::Int = FarmAgent.id,
    farm_status::Int,
    system::Int,
    msd::Date,
    seed::Int,
    optimal_stock::Int,
    optimal_lactating::Int,
    treatment_prob::Float64,
    treatment_length::Int,
    carrier_prob::Float64,
    timestep::Int,
    density_lactating::Int,
    density_dry::Int,
    density_calves::Int,
    date::Date,
    vacc_rate::Float64,
    fpt_rate::Float64,
    prev_r::Float64,
    prev_p::Float64,
    prev_cr::Float64,
    prev_cp::Float64,
    vacc_efficacy::Float64,
    pen_decon::Bool = false
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
    current_spring = current_autumn = optimal_spring = optimal_autumn = current_b1 = current_b2 = current_b3 = current_b4 = 0
    optimal_b1 = optimal_b2 = optimal_b3 = optimal_b4 = 0
    #Set up the model ====================================================
    sim = AnimalData([0], [Date(0)], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0],[0],[0],[0],[0],[0],[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]],[0],[0],[0],[0],[0],[0])
    contamination = zeros(250,250,30)
    contam_time = zeros(250,250,30)
    contam_type = zeros(250,250,30)
    pen_counter = 0
    calf_pen = 8
    transmission = Transmissions([0],[0], [0], [0], [0], [:none])
    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter, vacc_rate, fpt_rate, prev_r, prev_p, prev_cr, prev_cp, vacc_efficacy, current_autumn, optimal_autumn, current_spring, optimal_spring, current_b1, current_b2, current_b3, current_b4, optimal_b1, optimal_b2, optimal_b3, optimal_b4, sim, contamination, contam_time,contam_type, pen_counter, calf_pen, pen_decon, transmission)
    
    # Set the initial stock parameters
    animalModel.optimal_heifers = animalModel.optimal_dry = animalModel.optimal_weaned = animalModel.optimal_calves = animalModel.optimal_dh = animalModel.optimal_heifers = floor(0.3*animalModel.optimal_lactating)
    
    # Add the dry cows ---------------------------------------------

    animalModel.id_counter = 0
# Add the dry cows ---------------------------------------------
    #Dry stage is 6, Dry plane is 6. Model opens on day before psc
    animalModel.id_counter = 0
     for cow in 1:(animalModel.optimal_lactating - animalModel.optimal_heifers)
        animalModel.id_counter += 1
        id = Int(animalModel.id_counter)
        stage = Int(6)
        range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
        pos = [rand(animalModel.rng, 1:range, 2)..., stage]
         while pos in animalModel.positions == true
            pos = [rand(animalModel.rng,1:range, 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = 0
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
        days_recovered = Int(0)
        days_treated = Int(0)
        treatment = false
        pop_d = Float64(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
        dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
        dim = Int(0)
        pop_p = Float64(bacteriaSubmodel.pop_p)
        pop_r = Float64(bacteriaSubmodel.pop_r)
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
        lactation= round(age/365) - 1
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        carryover = false
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)
        clinical = false
        pen = 0
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)    
        push!(animalModel.animals, animal)
    end

# Add the heifers ---------------------------------------------
#Heifers about to calve, heifer stage 4
    for heifer in 1:animalModel.optimal_heifers
        animalModel.id_counter += 1
        id = Int(animalModel.id_counter)
        stage = 3
        range = Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers)))
        pos = [rand(animalModel.rng, 1:range, 2)..., stage]
         while pos in animalModel.positions == true
            pos = [rand(animalModel.rng,1:range, 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = 0
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
        days_recovered = Int(0)
        days_treated = Int(0)
        treatment = false
        pop_p = Float64(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
        pop_p = Float64(bacteriaSubmodel.pop_p)
        pop_r = Float64(bacteriaSubmodel.pop_r)
        dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
        dim = 0
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int(floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))) # Defined using initial age function
        lactation= 0
        pregstat = 1#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        carryover = false
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)
        clinical = false
        pen = 0
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)    
        push!(animalModel.animals, animal)
    end

     #Add weaned animals

    for weaned in 1:animalModel.optimal_weaned
        animalModel.id_counter += 1
        id = Int(animalModel.id_counter)
        stage = 2
        range = Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned)))
        pos = [rand(animalModel.rng, 1:range, 2)..., stage]
         while pos in animalModel.positions == true
            pos = [rand(animalModel.rng,1:range, 2)..., stage]
        end 
        push!(animalModel.positions, pos)
        status = 0
        days_infected = status == 1 || status == 2 ? 1 : 0
        days_exposed = Int(0)
        days_carrier = status == 5 || status == 6 ? 1 : 0
        days_recovered = Int(0)
        days_treated = Int(0)
        treatment = false
        pop_p = Float64(0.0)
        bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
        pop_p = Float64(bacteriaSubmodel.pop_p)
        pop_r = Float64(bacteriaSubmodel.pop_r)
        dic =  Int(0) #Gives a 63% ICR for this rng
        dim = 0
        stress = false
        sex = 1#Female
        calving_season = 0#Spring
        age = Int(floor(rand(truncated(Rayleigh(365),(295), (385))))) # Defined using initial age function
        lactation= 0
        pregstat = 0#Pregnant
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        carryover = false 
        fpt = false
        vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
        susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
        clinical = false
        pen = 0
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)    
        push!(animalModel.animals, animal)
    end
    #Distribute the initial infections
    num_r = Int(floor(animalModel.prev_r*length(animalModel.animals)))
    num_p = Int(floor(animalModel.prev_p*length(animalModel.animals)))
    num_cr = Int(floor(animalModel.prev_cr*length(animalModel.animals)))
    num_cp = Int(floor(animalModel.prev_cp*length(animalModel.animals)))
    
    #Set resistant 
    uninfected = findall(x-> x.status == 0, animalModel.animals)
    resistant = sample(uninfected, num_r)
    for resist in resistant
      animalModel.animals[resist].status = 4
      animalModel.animals[resist].bacteriaSubmodel.total_status = 4
      animalModel.animals[resist].days_exposed = 1
      animalModel.animals[resist].clinical = true
      bact_step!(animalModel.animals[resist].bacteriaSubmodel)
    end

    #Set pathogenic 
    uninfected = findall(x-> x.status == 0, animalModel.animals)
    pathogenic = sample(uninfected, num_p)
    for pathogen in pathogenic
      animalModel.animals[pathogen].status = 3
      animalModel.animals[pathogen].bacteriaSubmodel.total_status = 3
      animalModel.animals[pathogen].days_exposed = 1
      animalModel.animals[pathogen].clinical = true
      bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
    end

    #Set carrier resistant
    uninfected = findall(x-> x.status == 0, animalModel.animals)
    carrier_resistant = sample(uninfected, num_cr)
    for resist in carrier_resistant
      animalModel.animals[resist].status = 6
      animalModel.animals[resist].bacteriaSubmodel.total_status = 6
      animalModel.animals[resist].days_carrier = 1
      bact_step!(animalModel.animals[resist].bacteriaSubmodel)
    end

    #Set carrier pathogenic 
    uninfected = findall(x-> x.status == 0, animalModel.animals)
    carrier_pathogenic = sample(uninfected, num_cp)
    for pathogen in carrier_pathogenic
      animalModel.animals[pathogen].status = 5
      animalModel.animals[pathogen].bacteriaSubmodel.total_status = 5
      animalModel.animals[pathogen].days_carrier = 1
      bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
    end
    
    for animal in 1:length(animalModel.animals)
      animalModel.animals[animal].bacteriaSubmodel.rng = MersenneTwister(animalModel.animals[animal].id)
    end
    count_animals!(animalModel)

    optimal_stock = length(animalModel.animals)

    return animalModel

end


"""
initialiseBatch(;kwargs)
Initialise a batch calving farm
"""
function initialiseBatch(;
    farmno::Int = FarmAgent.id,
    farm_status::Int,
    system::Int,
    msd::Date,
    seed::Int,
    optimal_stock::Int,
    optimal_lactating::Int,
    treatment_prob::Float64,
    treatment_length::Int,
    carrier_prob::Float64,
    timestep::Int,
    density_lactating::Int,
    density_dry::Int,
    density_calves::Int,
    date::Date,
    vacc_rate::Float64,
    fpt_rate::Float64,
    prev_r::Float64,
    prev_p::Float64,
    prev_cr::Float64,
    prev_cp::Float64,
    vacc_efficacy::Float64,
    pen_decon::Bool
    )

 
    #Agent space =======================================================
    animals = Array{AnimalAgent}[]

    #Create the initial model parameters ===============================
    msd_2 = msd + Month(3)
    msd_3 = msd - Month(6)
    msd_4 = msd - Month(3)

    current_stock = 0
    current_lactating = 0
    current_dry = 0
    current_heifers = 0
    current_dh = 0
    current_weaned = 0
    current_calves = 0
    optimal_dry = 0
    optimal_heifers = 0
    optimal_dh = 0
    optimal_weaned = 0
    optimal_calves = 0
    tradeable_stock = 0
    sending = receiving = Array{AnimalAgent}(undef, 15)
    rng = MersenneTwister(seed)
    pop_p = 0
    pop_r = 0
    pop_s = 0
    pop_d = 0
    id_counter = 0
    positions = Array{Array{Int}}[]
    processed = false
    current_spring = current_autumn = optimal_spring = optimal_autumn = 0
    current_b1 = 0
    current_b2 = 0
    current_b3 = 0
    current_b4 = 0

    N = optimal_stock 
    optimal_b1 = optimal_b2 = optimal_b3 = optimal_b4 = floor(0.25*N)
    #Set up the model ====================================================
    sim = AnimalData([0], [Date(0)], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0],[0],[0],[0],[0],[0],[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]],[0],[0],[0],[0],[0],[0])
    contamination = zeros(250,250,30)
    contam_time = zeros(250,250,30)
    contam_type = zeros(250,250,30)
    pen_counter = 0
    calf_pen = 8
    transmission = Transmissions([0],[0], [0], [0], [0], [:none])
    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter, vacc_rate, fpt_rate, prev_r, prev_p, prev_cr, prev_cp, vacc_efficacy, current_autumn, optimal_autumn, current_spring, optimal_spring, current_b1, current_b2, current_b3, current_b4, optimal_b1, optimal_b2, optimal_b3, optimal_b4, sim, contamination, contam_time,contam_type, pen_counter, calf_pen, pen_decon, transmission)
    
    # Set the initial stock parameters
    animalModel.optimal_heifers = animalModel.optimal_weaned = animalModel.optimal_calves = animalModel.optimal_dh = animalModel.optimal_heifers = animalModel.optimal_dry = floor(0.3*animalModel.optimal_lactating)
    
    # Add the dry cows ---------------------------------------------

    animalModel.id_counter = 0

    for b1dry in 1:floor(N*0.25*0.7)
      animalModel.id_counter += 1
      id = Int(animalModel.id_counter)
      stage = 6
      range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
      push!(animalModel.positions, pos)
      status = Int(initial_status!(animalModel))
      days_infected = status == 1 || status == 2 ? 1 : 0
      days_exposed = Int(0)
      days_carrier = status == 5 || status == 6 ? 1 : 0
      days_recovered = Int(0)
      days_treated = Int(0)
      treatment = false
      pop_p = Float64(0.0)
      bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
      pop_p = Float64(bacteriaSubmodel.pop_p)
      pop_r = Float64(bacteriaSubmodel.pop_r)
      dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(262), 199, 283)))) #Gives a 63% ICR for this rng
      dim = 0
      stress = false
      sex = 1#Female
      calving_season = 1#Spring
      age =  Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
      lactation= 0
      pregstat = 1#Pregnant
      trade_status = 0#false
      neighbours = get_neighbours_animal(pos)
      carryover = false 
      fpt = false
      vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
      susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
      clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
  end


  for b1heifers in 1:floor(N*0.25*0.3)
    animalModel.id_counter += 1
    id = Int(animalModel.id_counter)
    stage = 3
    range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
    pos = [rand(animalModel.rng, 1:range, 2)..., stage]
    while pos in animalModel.positions == true
        pos = [rand(animalModel.rng,1:range, 2)..., stage]
    end 
    push!(animalModel.positions, pos)
    status = Int(initial_status!(animalModel))
    days_infected = status == 1 || status == 2 ? 1 : 0
    days_exposed = Int(0)
    days_carrier = status == 5 || status == 6 ? 1 : 0
    days_recovered = Int(0)
    days_treated = Int(0)
    treatment = false
    pop_p = Float64(0.0)
    bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
    pop_p = Float64(bacteriaSubmodel.pop_p)
    pop_r = Float64(bacteriaSubmodel.pop_r)
    dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(272), 199, 283)))) #Gives a 63% ICR for this rng
    dim = 0
    stress = false
    sex = 1#Female
    calving_season = 1#Spring
    age =  Int(floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))) # Defined using initial age function
    lactation= 0
    pregstat = 1#Pregnant
    trade_status = 0#false
    neighbours = get_neighbours_animal(pos)
    carryover = false 
    fpt = false
    vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
    susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
    clinical = false
    pen = 0
    animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
    push!(animalModel.animals, animal)
end


for b1weaned in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 2
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dic =  0 #Gives a 63% ICR for this rng
  dim = 0
  stress = false
  sex = 1#Female
  calving_season = 1#Spring
  age =  Int(floor(rand(truncated(Rayleigh(315),(281), (365))))) # Defined using initial age function
  lactation= 0
  pregstat = 0#Pregnant
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b2lac in 1:floor(N*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 5
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim = Int(floor(rand(animalModel.rng, truncated(Rayleigh(237), 189, 273))))
  stress = false
  sex = 1#Female
  calving_season = 2#Spring
  age =  Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365))))) # Defined using initial age function
  lactation= 0
  pregstat = rand(animalModel.rng) < 0.85 ? 1 : 0#Pregnant
  dic = pregstat == 1 ? Int(floor(rand(animalModel.rng, truncated(Rayleigh(153), 85, 188)))) : 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b2dheifers in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 4
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim = 0
  stress = false
  sex = 1#Female
  calving_season = 2#Spring
  age =  Int(floor(rand(truncated(Rayleigh(603),553, 638)))) # Defined using initial age function
  lactation= 0
  pregstat = 1#Pregnant
  dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(174), 126, 209))))
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b2weaned in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 2
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim = 0
  stress = false
  sex = 1#Female
  calving_season = 2#Spring
  age =   Int(floor(rand(animalModel.rng, truncated(Rayleigh(237), 189, 273))))# Defined using initial age function
  lactation= 0
  pregstat = 0#Pregnant
  dic = 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end


for b3lac in 1:floor(N*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 5
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(145), 97, 180))))
  stress = false
  sex = 1#Female
  calving_season = 3#Spring
  age =   Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365)))))# Defined using initial age function
  lactation= 0
  pregstat = rand(animalModel.rng) < 0.85 ? 1 : 0#Pregnant
  dic = pregstat == 1 ? Int(floor(rand(animalModel.rng, truncated(Rayleigh(153), 85, 188)))) : 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b3heifers in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 3
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(145), 97, 180))))
  stress = false
  sex = 1#Female
  calving_season = 3#Spring
  age =  Int(floor(rand(truncated(Rayleigh(511),463, 546))))# Defined using initial age function
  lactation= 0
  pregstat = 1 #Pregnant
  dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(82), 33, 117))))
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b3weaned in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 2
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  0
  stress = false
  sex = 1#Female
  calving_season = 3#Spring
  age =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(145), 97, 180))))# Defined using initial age function
  lactation= 0
  pregstat = 0 #Pregnant
  dic = 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end


for b4lac in 1:floor(N*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 5
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(55), 7, 90))))
  stress = false
  sex = 1#Female
  calving_season = 4#Spring
  age =  Int(floor(rand(truncated(Rayleigh(4*365),(2*365), (8*365)))))# Defined using initial age function
  lactation= 0
  pregstat = 0 #Pregnant
  dic = 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end

for b4dheifers in 1:floor(N*0.25*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 4
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  0
  stress = false
  sex = 1#Female
  calving_season = 4#Spring
  age =   Int(floor(rand(truncated(Rayleigh(420),372, 455))))# Defined using initial age function
  lactation= 0
  pregstat = 0 #Pregnant
  dic = 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end


for b4calves in 1:floor(N*0.25*0.5)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = 1
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_calves))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_calves)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_p = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  dim =  0
  stress = false
  sex = 1#Female
  calving_season = 4#Spring
  age =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(55), 7, 90))))# Defined using initial age function
  lactation= 0
  pregstat = 0 #Pregnant
  dic = 0
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false 
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
  clinical = false
      pen = 8
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)
end


#Distribute the initial infections
num_r = Int(floor(animalModel.prev_r*length(animalModel.animals)))
num_p = Int(floor(animalModel.prev_p*length(animalModel.animals)))
num_cr = Int(floor(animalModel.prev_cr*length(animalModel.animals)))
num_cp = Int(floor(animalModel.prev_cp*length(animalModel.animals)))

#Set resistant 
uninfected = findall(x-> x.status == 0, animalModel.animals)
resistant = sample(uninfected, num_r)
for resist in resistant
  animalModel.animals[resist].status = 4
  animalModel.animals[resist].bacteriaSubmodel.total_status = 4
  animalModel.animals[resist].days_exposed = 1
  animalModel.animals[resist].clinical = true
  bact_step!(animalModel.animals[resist].bacteriaSubmodel)
end

#Set pathogenic 
uninfected = findall(x-> x.status == 0, animalModel.animals)
pathogenic = sample(uninfected, num_p)
for pathogen in pathogenic
  animalModel.animals[pathogen].status = 3
  animalModel.animals[pathogen].bacteriaSubmodel.total_status = 3
  animalModel.animals[pathogen].days_exposed = 1
  animalModel.animals[pathogen].clinical = true
  bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
end

#Set carrier resistant
uninfected = findall(x-> x.status == 0, animalModel.animals)
carrier_resistant = sample(uninfected, num_cr)
for resist in carrier_resistant
  animalModel.animals[resist].status = 6
  animalModel.animals[resist].bacteriaSubmodel.total_status = 6
  animalModel.animals[resist].days_carrier = 1
  bact_step!(animalModel.animals[resist].bacteriaSubmodel)
end

#Set carrier pathogenic 
uninfected = findall(x-> x.status == 0, animalModel.animals)
carrier_pathogenic = sample(uninfected, num_cp)
for pathogen in carrier_pathogenic
  animalModel.animals[pathogen].status = 5
  animalModel.animals[pathogen].bacteriaSubmodel.total_status = 5
  animalModel.animals[pathogen].days_carrier = 1
  bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
end

for animal in 1:length(animalModel.animals)
  animalModel.animals[animal].bacteriaSubmodel.rng = MersenneTwister(animalModel.animals[animal].id)
end

  count_animals!(animalModel)

  optimal_stock = length(animalModel.animals)


  return animalModel


end

"""
initialiseSplit!(kwargs)
Initialise a split calving system
"""
function initialiseSplit(;
  farmno::Int = FarmAgent.id,
  farm_status::Int,
  system::Int,
  msd::Date,
  seed::Int,
  optimal_stock::Int,
  optimal_lactating::Int,
  treatment_prob::Float64,
  treatment_length::Int,
  carrier_prob::Float64,
  timestep::Int,
  density_lactating::Int,
  density_dry::Int,
  density_calves::Int,
  date::Date,
  vacc_rate::Float64,
  fpt_rate::Float64,
  prev_r::Float64,
  prev_p::Float64,
  prev_cr::Float64,
  prev_cp::Float64,
  vacc_efficacy::Float64, 
  pen_decon::Bool
  )
  
  #Agent space =======================================================
  animals = Array{AnimalAgent}[]

  #Create the initial model parameters ===============================
  msd_2 = msd - Month(4)
  msd_3 = msd_4 = Date(0)
  current_stock = 0
  current_lactating = 0
  current_dry = 0
  current_heifers = 0
  current_dh = 0
  current_weaned = 0
  current_calves = 0
  optimal_dry = optimal_heifers = optimal_dh = optimal_weaned = optimal_calves = 0
  tradeable_stock = 0
  sending = receiving = Array{AnimalAgent}(undef, 15)
  rng = MersenneTwister(seed)
  pop_p = 0
  pop_r = 0
  pop_s = 0
  pop_d = 0
  id_counter = 0
  positions = Array{Array{Int}}[]
  processed = false

  N = optimal_stock
  optimal_spring = optimal_autumn = Int(floor(N*0.5))
  current_spring = Int(0)
  current_autumn = Int(0) 

  current_b1 = current_b2 = current_b3 = current_b4 = 0
  optimal_b1 = optimal_b2 = optimal_b3 = optimal_b4 = 0
  #Set up the model ====================================================
  sim = AnimalData([0], [Date(0)], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0],[0],[0],[0],[0],[0],[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]],[0],[0],[0],[0],[0],[0])
  contamination = zeros(250,250,30)
    contam_time = zeros(250,250,30)
    contam_type = zeros(250,250,30)
    pen_counter = 0
    calf_pen = 8
    transmission = Transmissions([0],[0], [0], [0], [0], [:none])
    animalModel = AnimalModel(farmno, animals, timestep, date, rng, system, msd, msd_2, msd_3, msd_4, seed, farm_status, optimal_stock, treatment_prob, treatment_length, carrier_prob, current_stock, current_lactating, optimal_lactating, current_heifers, optimal_heifers, current_calves, optimal_calves, current_weaned, optimal_weaned, current_dh, optimal_dh, current_dry, optimal_dry, tradeable_stock, sending, receiving, density_lactating, density_calves, density_dry, positions, pop_r, pop_s, pop_p, pop_d, id_counter, vacc_rate, fpt_rate, prev_r, prev_p, prev_cr, prev_cp, vacc_efficacy, current_autumn, optimal_autumn, current_spring, optimal_spring, current_b1, current_b2, current_b3, current_b4, optimal_b1, optimal_b2, optimal_b3, optimal_b4, sim, contamination, contam_time,contam_type, pen_counter, calf_pen, pen_decon, transmission)
    
  #Set up the model ====================================================

  
  # Set the initial stock parameters
  animalModel.optimal_heifers = animalModel.optimal_weaned = animalModel.optimal_calves = animalModel.optimal_dh = animalModel.optimal_heifers = animalModel.optimal_dry = floor(0.3*animalModel.optimal_lactating)
  
  
  #Set the animal number generator to 0
  animalModel.id_counter = 0
   # Add the dry cows ---------------------------------------------
  #Dry stage is 6, Dry plane is 6. Model opens on day before psc
   for cow in 1:animalModel.optimal_spring
      animalModel.id_counter += 1
      id = Int(animalModel.id_counter)
      stage = 6
      range = Int(floor(√(animalModel.density_dry*animalModel.optimal_dry))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_dry)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
      while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
      push!(animalModel.positions, pos)
      status = Int(initial_status!(animalModel))
      days_infected = status == 1 || status == 2 ? 1 : 0
      days_exposed = Int(0)
      days_carrier = status == 5 || status == 6 ? 1 : 0
      days_recovered = Int(0)
      days_treated = Int(0)
      treatment = false
      pop_d = Float64(0.0)
      bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
      dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
      dim = Int(0)
      pop_p = Float64(bacteriaSubmodel.pop_p)
      pop_r = Float64(bacteriaSubmodel.pop_r)
      stress = false
      sex = 1#Female
      calving_season = 1#Split1
      age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
      lactation= round(age/365) - 1
      pregstat = 1#Pregnant
      trade_status = 0#false
      neighbours = get_neighbours_animal(pos)
      carryover = false
      fpt = false
      vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
      susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)
      clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)       
      push!(animalModel.animals, animal)

    end

# Add the heifers ---------------------------------------------
#Heifers about to calve, heifer stage 4
  for heifer in 1:floor(animalModel.optimal_spring*0.25)
      animalModel.id_counter += 1
      id = Int(animalModel.id_counter)
      stage = 4
      range = Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
       while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
      push!(animalModel.positions, pos)
      status = Int(initial_status!(animalModel))
      days_infected = status == 1 || status == 2 ? 1 : 0
      days_exposed = Int(0)
      days_carrier = status == 5 || status == 6 ? 1 : 0
      days_recovered = Int(0)
      days_treated = Int(0)
      treatment = false
      pop_p = Float64(0.0)
      bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
      pop_p = Float64(bacteriaSubmodel.pop_p)
      pop_r = Float64(bacteriaSubmodel.pop_r)
      dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 280)))) #Gives a 63% ICR for this rng
      dim = 0
      stress = false
      sex = 1#Female
      calving_season = 1#Split1
      age = Int(floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))) # Defined using initial age function
      lactation= 0
      pregstat = 1#Pregnant
      trade_status = 0#false
      neighbours = get_neighbours_animal(pos)
      carryover = false
      fpt = false
      vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
      susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)
      clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen) 
      push!(animalModel.animals, animal)
  end

   #Add weaned animals

  for weaned in 1:floor(animalModel.optimal_spring*0.25)
      animalModel.id_counter += 1
      id = Int(animalModel.id_counter)
      stage = 2
      range = Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned)))
      pos = [rand(animalModel.rng, 1:range, 2)..., stage]
       while pos in animalModel.positions == true
          pos = [rand(animalModel.rng,1:range, 2)..., stage]
      end 
      push!(animalModel.positions, pos)
      status = Int(initial_status!(animalModel))
      days_infected = status == 1 || status == 2 ? 1 : 0
      days_exposed = Int(0)
      days_carrier = status == 5 || status == 6 ? 1 : 0
      days_recovered = Int(0)
      days_treated = Int(0)
      treatment = false
      pop_p = Float64(0.0)
      bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
      pop_p = Float64(bacteriaSubmodel.pop_p)
      pop_r = Float64(bacteriaSubmodel.pop_r)
      dic =  Int(0) #Gives a 63% ICR for this rng
      dim = 0
      stress = false
      sex = 1#Female
      calving_season = 1#Spring
      age = Int(floor(rand(truncated(Rayleigh(365),(295), (385))))) # Defined using initial age function
      lactation= 0
      pregstat = 0#Pregnant
      trade_status = 0#false
      neighbours = get_neighbours_animal(pos)
      carryover = false 
      fpt = false
      vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
      susceptibility = vaccinated == true ?  animalModel.vacc_efficacy  : rand(0.45:0.01:0.55)
      
      clinical = false
      pen = 0
      animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)              
      push!(animalModel.animals, animal)
  end


#Calving period 2  ----------------

 #Lactating autumn cows
 for cow in 1:optimal_autumn
    animalModel.id_counter += 1
    id = Int(animalModel.id_counter)
    stage = Int(5)
    range = Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_lactating)))
    pos = [rand(animalModel.rng, 1:range, 2)..., stage]
     while pos in animalModel.positions == true
        pos = [rand(animalModel.rng,1:range, 2)..., stage]
    end 
    push!(animalModel.positions, pos)
    status = Int(initial_status!(animalModel))
    days_infected = status == 1 || status == 2 ? 1 : 0
    days_exposed = Int(0)
    days_carrier = status == 5 || status == 6 ? 1 : 0
    days_recovered = Int(0)
    days_treated = Int(0)
    treatment = false
    pop_d = Float64(0.0)
    bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
    dic =  ifelse(rand(animalModel.rng) < 0.85, Int(floor(rand(animalModel.rng, truncated(Rayleigh(33), 31, 123)))), 0) #Gives a 63% ICR for this rng
    dim = Int(floor(rand(animalModel.rng, truncated(Rayleigh(100), 37, 121))))
    pop_p = Float64(bacteriaSubmodel.pop_p)
    pop_r = Float64(bacteriaSubmodel.pop_r)
    stress = false
    sex = 1#Female
    calving_season = 2#Split2
    age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
    lactation= round(age/365) - 1
    pregstat = ifelse(dic == 0, 0, 1)#Pregnant
    trade_status = 0#false
    neighbours = get_neighbours_animal(pos)
    carryover = false
    fpt = false
    vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
    susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)


    clinical = false
    pen = 0
    animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)  
    
    push!(animalModel.animals, animal)
end

#Split 2 heifers ------------------

for cow in 1:floor(animalModel.optimal_autumn*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = Int(4)
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_heifers)))
  pos = [rand(animalModel.rng, 1:range, 2)..., stage]
  while pos in animalModel.positions == true
      pos = [rand(animalModel.rng,1:range, 2)..., stage]
  end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_d = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  dic =  Int(floor(rand(truncated(Rayleigh(42),(1), (60))))) #Gives a 63% ICR for this rng
  dim = 0
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  stress = false
  sex = 1#Female
  calving_season = 2#Split2
  age = Int(floor(rand(truncated(Rayleigh(2*365 - 4*30),(22*30 - 4*30), (25*30 - 4*30)))))# Defined using initial age function
  lactation= round(age/365) - 1
  pregstat = 1#Pregnant
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)

  clinical = false
  pen = 0
  animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)          
  push!(animalModel.animals, animal)
end

# Split2 weaned

for cow in 1:floor(animalModel.optimal_autumn*0.25)
  animalModel.id_counter += 1
  id = Int(animalModel.id_counter)
  stage = Int(2)
  range = Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned))) > 250 ? 250 : Int(floor(√(animalModel.density_dry*animalModel.optimal_weaned)))
  pos = [rand(animalModel.rng, 1:range, 2)..., stage]
   while pos in animalModel.positions == true
      pos = [rand(animalModel.rng,1:range, 2)..., stage]
  end 
  push!(animalModel.positions, pos)
  status = Int(initial_status!(animalModel))
  days_infected = status == 1 || status == 2 ? 1 : 0
  days_exposed = Int(0)
  days_carrier = status == 5 || status == 6 ? 1 : 0
  days_recovered = Int(0)
  days_treated = Int(0)
  treatment = false
  pop_d = Float64(0.0)
  bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
  dic =  0 #Gives a 63% ICR for this rng
  dim = 0
  pop_p = Float64(bacteriaSubmodel.pop_p)
  pop_r = Float64(bacteriaSubmodel.pop_r)
  stress = false
  sex = 1#Female
  calving_season = 2#Split2
  age = Int(floor(rand(animalModel.rng, truncated(Rayleigh(100), 37, 121))))# Defined using initial age function
  lactation= round(age/365) - 1
  pregstat = 1#Pregnant
  trade_status = 0#false
  neighbours = get_neighbours_animal(pos)
  carryover = false
  fpt = false
  vaccinated = rand(animalModel.rng) < animalModel.vacc_rate ? true : false
  susceptibility = vaccinated == true ?  animalModel.vacc_efficacy : rand(0.45:0.01:0.55)

  clinical = false
  pen = 0
  animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)          
  push!(animalModel.animals, animal)
end

#Distribute the initial infections
num_r = Int(floor(animalModel.prev_r*length(animalModel.animals)))
num_p = Int(floor(animalModel.prev_p*length(animalModel.animals)))
num_cr = Int(floor(animalModel.prev_cr*length(animalModel.animals)))
num_cp = Int(floor(animalModel.prev_cp*length(animalModel.animals)))

#Set resistant 
uninfected = findall(x-> x.status == 0, animalModel.animals)
resistant = sample(uninfected, num_r)
for resist in resistant
  animalModel.animals[resist].status = 4
  animalModel.animals[resist].bacteriaSubmodel.total_status = 4
  animalModel.animals[resist].days_exposed = 1
  animalModel.animals[resist].clinical = true
  bact_step!(animalModel.animals[resist].bacteriaSubmodel)
end

#Set pathogenic 
uninfected = findall(x-> x.status == 0, animalModel.animals)
pathogenic = sample(uninfected, num_p)
for pathogen in pathogenic
  animalModel.animals[pathogen].status = 3
  animalModel.animals[pathogen].bacteriaSubmodel.total_status = 3
  animalModel.animals[pathogen].days_exposed = 1
  animalModel.animals[pathogen].clinical = true
  bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
end

#Set carrier resistant
uninfected = findall(x-> x.status == 0, animalModel.animals)
carrier_resistant = sample(uninfected, num_cr)
for resist in carrier_resistant
  animalModel.animals[resist].status = 6
  animalModel.animals[resist].bacteriaSubmodel.total_status = 6
  animalModel.animals[resist].days_carrier = 1
  bact_step!(animalModel.animals[resist].bacteriaSubmodel)
end

#Set carrier pathogenic 
uninfected = findall(x-> x.status == 0, animalModel.animals)
carrier_pathogenic = sample(uninfected, num_cp)
for pathogen in carrier_pathogenic
  animalModel.animals[pathogen].status = 5
  animalModel.animals[pathogen].bacteriaSubmodel.total_status = 5
  animalModel.animals[pathogen].days_carrier = 1
  bact_step!(animalModel.animals[pathogen].bacteriaSubmodel)
end

for animal in 1:length(animalModel.animals)
  animalModel.animals[animal].bacteriaSubmodel.rng = MersenneTwister(animalModel.animals[animal].id)
end

  count_animals!(animalModel)

  optimal_stock = length(animalModel.animals)

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

        if animal.status == 5 && animal.days_exposed == 0
          bact_step!(animal.bacteriaSubmodel)
        elseif animal.status == 6 && animal.days_exposed == 0 
          bact_step!(animal.bacteriaSubmodel)
        elseif animal.status == 7 && animal.days_recovered < 55
          bact_step!(animal.bacteriaSubmodel)
        elseif animal.status == 8 && animal.days_recovered < 55
          bact_step!(animal.bacteriaSubmodel)
        elseif animal.status == 1 || animal.status == 2
          bact_step!(animal.bacteriaSubmodel)
        elseif (animal.status == 3 || animal.status == 4)
          bact_step!(animal.bacteriaSubmodel)
        elseif (animal.status == 5 || animal.status ==6) && animal.stress == true
          bact_step!(animal.bacteriaSubmodel)
        end
        

        animal.pop_r = bacteriaSubmodel.pop_r
        animal.pop_p = bacteriaSubmodel.pop_p
end


"""
animal_mortality!(animalModel. position)
Determine animal mortality if infected
"""

  function animal_mortality!(animalModel, animal)
    animal.status ∉ [1,2] && return
    #if animal.status == 1 || animal.status == 2
    animal.stage == 0 && return
    if animal.stage == 1 
      if animal.clinical == false && rand(animalModel.rng) < rand(animalModel.rng, 0.01:0.001:0.05)
        cull!(animal, animalModel)
        #@info "Calf mortality!"
      elseif animal.clinical == false && rand(animalModel.rng) < rand(animalModel.rng, 0.01:0.001:0.15)
        cull!(animal, animalModel)
        #@info "Calf mortality!"
      end
    elseif rand(animalModel.rng) < rand(animalModel.rng, 0.0001:0.0001:0.001)
      cull!(animal, animalModel)
      #@info "Cow mortality!"
    end
    
   # println("Mortality")
    
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
  #animal.status ∉ [1,2] && return
  if animal.status == 1 || animal.status == 2
    animal.days_infected == 0 && return
    if animal.days_infected >= rand(3:7)
      if rand(animalModel.rng) > animalModel.carrier_prob
            if animal.status == 1
              animal.days_infected = 0
              animal.days_recovered = 1
              animal.bacteriaSubmodel.days_recovered = 1
              animal.status = animal.bacteriaSubmodel.total_status =  7
              bact_step!(animal.bacteriaSubmodel)
            elseif animal.status == 2
              animal.days_infected = 0
              animal.days_recovered = 1
              animal.bacteriaSubmodel.days_recovered = 1
              animal.status = animal.bacteriaSubmodel.total_status = 8
              bact_step!(animal.bacteriaSubmodel)
            end
      elseif rand(animalModel.rng) <= animalModel.carrier_prob
          if animal.status == 2
            animal.days_infected = 0
            animal.days_carrier = 1
            animal.status = animal.bacteriaSubmodel.total_status = 6
            bact_step!(animal.bacteriaSubmodel)
          elseif animal.status == 1
            animal.days_infected = 0
            animal.days_carrier = 1
            animal.status = animal.bacteriaSubmodel.total_status =  5
            bact_step!(animal.bacteriaSubmodel)
          end
      end
    end
    end
end

function contamination!(animal, animalModel)
  animal.status ∉ [1,2,5,6,7,8] && return
  #if animal.status in [1,2]
    animalModel.contamination[animal.pos[1], animal.pos[2], animal.pos[3]] = exp(animal.pop_r + animal.pop_p)/10
    animalModel.contam_time[animal.pos[1], animal.pos[2], animal.pos[3]] = 1
    animalModel.contam_type[animal.pos[1], animal.pos[2], animal.pos[3]] = ifelse(animal.status % 2 ==0, 2, 1)
  #else
   # animalModel.contamination[animal.pos[1], animal.pos[2], animal.pos[3]] = exp(animal.pop_r + animal.pop_p)/10
  #end
end

function environmental_transmission!(animal, animalModel)
  animal.status ∉ [0,7,8] && return
  animalModel.contamination[animal.pos[1], animal.pos[2], animal.pos[3]] == 0.0 && return
  rand(animalModel.rng) > animal.susceptibility && return
  #animal.susceptibility > animalModel.contamination[animal.pos[1], animal.pos[2], animal.pos[3]] && return
  rand(animalModel.rng) > animalModel.contamination[animal.pos[1], animal.pos[2], animal.pos[3]] && return
  month(animalModel.date) in [10,11,12,1,2] && rand(animalModel.rng) > 0.1 && return
  month(animalModel.date) in [3,4,5,9] && rand(animalModel.rng) > 0.8 && return
  if animalModel.contam_type[animal.pos[1], animal.pos[2], animal.pos[3]] % 2 == 0
    if animal.status == 1
      rand(animalModel.rng) < rand(0.6:1.0) ? animal.clinical = true : animal.clinical = false
    else
      rand(animalModel.rng) < rand(0.01:0.05) ? animal.clinical = true : animal.clinical = false
    end
    animal.status = 4
    animal.days_exposed = 1
    animal.bacteriaSubmodel.clinical = animal.clinical
    animal.bacteriaSubmodel.days_exposed = 1
    animal.bacteriaSubmodel.total_status = 4
    bact_step!(animal.bacteriaSubmodel)
    #@info "environmental transmission"
    record_transmission!(animalModel, animal.id, animal.stage, 999, animal.status, :ee)

  else
    animal.status = 3
    animal.days_exposed = 1
    animal.bacteriaSubmodel.days_exposed = 1
    animal.bacteriaSubmodel.total_status = 3
    bact_step!(animal.bacteriaSubmodel)
    #@info "environmental transmission"
    record_transmission!(animalModel, animal.id, animal.stage, 999, animal.status, :ee)

  end
end

function calfeteria!(animalModel, sex)
  for pen in 8:30
    calves = findall(x-> x.stage == 1 && x.sex == sex && x.pen == pen, animalModel.animals)
    buddies = Array{Int}(undef,2)
    for calf in calves
      transmitter = animalModel.animals[calf]
      transmitter.status ∉ [1,2,5,6,7,8] && continue
      transmitter.clinical == false && rand(animalModel.rng) < 0.5 && continue

      buddies = sample(calves,rand(0:4))
      while calf in buddies
        buddies = sample(calves,rand(0:4))
      end
      
      for bud in buddies
        atrisk = animalModel.animals[bud]
        atrisk.status ∉ [0,7,8] && continue
        rand(animalModel.rng) > atrisk.susceptibility && continue
        (transmitter.status % 2 == 0 && (transmitter.pop_r < rand(animalModel.rng))) && continue
        (transmitter.status % 2 != 0 && (transmitter.pop_p < rand(animalModel.rng))) && continue
        transmitter.status % 2 == 0 ? atrisk.status = 4 : atrisk.status = 3
        rand(animalModel.rng) < rand(0.6:1.0) ? atrisk.clinical = true : atrisk.clinical = false
        atrisk.days_exposed = 1
        atrisk.bacteriaSubmodel.total_status = atrisk.status
        atrisk.bacteriaSubmodel.clinical = atrisk.clinical
        bact_step!(atrisk.bacteriaSubmodel)
        record_transmission!(animalModel, atrisk.id, atrisk.stage, transmitter.status, atrisk.status, :cc)

        #@info "Infection at feeding"
      end
    end
  end
end



"""
animal_transmission!(animal)
Transmit infection between animals.
Only infected, recovering or carrier animals can transmit to their neighbours
"""
function animal_transmission!(animal, animalModel)
  
   animal.status == 0 && return
   animal.status == 4 && return
   animal.status == 3 && return
   

   animal.status == 7 && animal.days_recovered > rand(1:55) && return
   animal.status == 8 && animal.days_recovered > rand(1:55) && return

    pos = animal.pos
    animal.neighbours = get_neighbours_animal(pos)
    animal.processed == true && return

    (animal.status == 1 && (rand(animalModel.rng) > animalModel.pop_p)) && return
    (animal.status == 2 && (rand(animalModel.rng) > animalModel.pop_r)) && return
    (animal.status == 5 && (rand(animalModel.rng) > animalModel.pop_p)) && return
    (animal.status == 6 && (rand(animalModel.rng) > animalModel.pop_r)) && return
    (animal.status == 7 && (rand(animalModel.rng) > animalModel.pop_p)) && return
    (animal.status == 8 && (rand(animalModel.rng) > animalModel.pop_r)) && return 

    

    #The animal can now go on to infect its neighbours
    competing_neighbours = []

      for i in 1:length(animal.neighbours) 
 
          for x in 1:length(animalModel.animals)           
              if animalModel.animals[x].pos == animal.neighbours[i]
                  push!(competing_neighbours, animalModel.animals[x])             
              end
          end
        end   

        #println(length(competing_neighbours))
        
        for competing_neighbour in competing_neighbours
        competing_neighbour === nothing && continue
        
        competing_neighbour.status ∉ [0,7,8] && continue

            if competing_neighbour.susceptibility > rand(animalModel.rng)
              if competing_neighbour.status == 1
                rand(animalModel.rng) < rand(0.3:0.6) ? competing_neighbour.clinical = true : competing_neighbour.clinical = false
              else
                rand(animalModel.rng) < rand(0.01:0.05) ? competing_neighbour.clinical = true : competing_neighbour.clinical = false
              end
              animal.clinical == false && rand(animalModel.rng) < 0.5 && continue
              animal.status % 2 == 0 ? competing_neighbour.status = 4 : competing_neighbour.status = 3
              animal.status % 2 == 0 ? competing_neighbour.bacteriaSubmodel.total_status = 4 : competing_neighbour.bacteriaSubmodel.total_status = 3
              #competing_neighbour.bacteriaSubmodel.total_status = deepcopy(competing_neighbour.status)
              competing_neighbour.days_exposed = 1
              competing_neighbour.bacteriaSubmodel.days_exposed = 1
              competing_neighbour.bacteriaSubmodel.clinical = competing_neighbour.clinical
              bact_step!(competing_neighbour.bacteriaSubmodel)
              competing_neighbour.processed = true

              record_transmission!(animalModel, competing_neighbour.id, competing_neighbour.stage, animal.status, competing_neighbour.status, :aa)
             #=  if animal.status == 5 || animal.status == 6
                #@info "Carrier transmission"
              end
              stat2 = competing_neighbour.status
               #@info "Disease was transmitted by $from to $to ($stat to $stat2)"  =#
            end
          end
    end

function record_transmission!(animalModel, id, stage, from, to, type)
  push!(animalModel.transmissions.step, animalModel.timestep)
  push!(animalModel.transmissions.id, id)
  push!(animalModel.transmissions.stage, stage)
  push!(animalModel.transmissions.from, from)
  push!(animalModel.transmissions.to, to)
  push!(animalModel.transmissions.type, type)
end



"""
animal_shedding!(animal)
Recrudescent infection from carrier animals
"""
function animal_shedding!(animal)
  #rand(animalModel.rng) < 0.5 && return
    if (animal.status == 5 || animal.status == 6) && animal.stress == true
      if animal.status == 5
        animal.bacteriaSubmodel.days_exposed = 1
        animal.bacteriaSubmodel.total_status = 3
        animal.clinical = true
      elseif animal.status == 6
        animal.bacteriaSubmodel.days_exposed = 1
        animal.bacteriaSubmodel.total_status = 4
        animal.clinical = true
      end
    elseif (animal.status == 5 || animal.status == 6) && animal.stress == false
      if animal.status == 5
        animal.bacteriaSubmodel.days_exposed = 0
        animal.bacteriaSubmodel.total_status = 5
        animal.bacteriaSubmodel.days_carrier = 1
        animal.clinical = false
      elseif animal.status == 6
        animal.bacteriaSubmodel.days_exposed = 0
        animal.bacteriaSubmodel.total_status = 6
        animal.bacteriaSubmodel.days_carrier = 1
        animal.clinical = false
      end
    end
  end

"""
animal_susceptiblility(animal, animalModel)
Animals return to susceptibility at a variable interval after recovery, simulates waning immunity
"""

  function animal_susceptiblility!(animal, animalModel)
      animal.status ∉ [7,8] && return
      animal.susceptibility = ℯ^(-4500/animal.days_recovered)   
end

"""
animal_treatment!(animal, animalModel)
Decide to treat animals
"""

  function animal_treatment!(animal, animalModel)
    animal.treatment == true && return
    if animal.status == 1 || animal.status == 2 
       rand(animalModel.rng) > animalModel.treatment_prob && return
      animal.days_treated = 1
      animal.treatment = true
      animal.bacteriaSubmodel.days_treated = 1
    end
end

"""
animal_fpt_vacc(animal)
Adapt animal susceptibility based on vaccination status
"""
function animal_fpt_vacc!(animal, animalModel)
  animal.stage != 1 && return
  if animal.fpt == true && animal.age <= 10
    if animal.age == 1
      animal.susceptibility = rand(animalModel.rng, 0.9:0.01:1.0)
    elseif animal.age >1 
      animal.susceptibility = (animal.susceptibility*(1-0.05))^animal.age
    end
  end

  if animal.fpt == false && animal.age <= 10
    animal.susceptibility = (animal.susceptibility*(1+0.05))^animal.age
  elseif animal.fpt == true && animal.age > 10
    animal.vaccinated == true && return
    animal.susceptibility = rand(0.45:0.01:0.55)
  end

  if animal.age == 54 && rand(animalModel.rng) < animalModel.vacc_rate
    animal.vaccinated = true
    animal.susceptibility = animalModel.vacc_efficacy*rand(0.95:0.01:1.05)
    #@info "Vaccinated!"
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
    stock_in_class <= 0 ? range = 10 : range = Int(floor(√(density*stock_in_class)))

    range > 250 ? range = 250 : range = range
    oldpos = animal.pos
    newpos = [rand(animalModel.rng, 1:range, 2)...,stage]

    while newpos in animalModel.positions == true
        newpos = [rand(animalModel.rng, 1:range, 2)...,stage]
    end
    ind = getloc(animalModel, oldpos)
    ind === nothing && return
    deleteat!(animalModel.positions,ind)

    animal.pos = newpos

    push!(animalModel.positions, newpos)
end

"""
move_calf!(animal, animalModel)
Move Calves
"""

  function move_calf!(animal, animalModel)
    if animal.sex == 1 && animal.age == 1
      if animalModel.pen_counter > 15
        animalModel.pen_counter = 0
        if animalModel.pen_decon == true 
          animalModel.calf_pen < 30 ? animalModel.calf_pen += 1 : animalModel.calf_pen = 8
        else
          animalModel.calf_pen < 18 ? animalModel.calf_pen += 1 : animalModel.calf_pen = 8
        end
        animal.pen = animalModel.calf_pen
        move_animal!(animal, animalModel, animalModel.calf_pen, animalModel.density_calves, 15)
      else 
        animal.pen = animalModel.calf_pen
        move_animal!(animal, animalModel, animalModel.calf_pen, animalModel.density_calves, 15)
      end
    elseif animal.sex == 0 && animal.age == 1
      animal.pen = 7
      bobbies = length(findall(x-> x.stage == 1 && x.sex == 0, animalModel.animals))
      move_animal!(animal, animalModel, 7, animalModel.density_calves, bobbies)
    end

    if animal.age > 1
      move_animal!(animal, animalModel, animal.pen, animalModel.density_calves, 15)
    end
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
    if animalModel.system == 1
      animalModel.current_lactating -= 1
    elseif animalModel.system == 2
      if animal.calving_season == 1
        animalModel.current_spring -= 1
      else
        animalModel.current_autumn -= 1
      end
    end
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
   if animalModel.system == 1
    animalModel.current_lactating -= 1
  elseif animalModel.system == 2
    if animal.calving_season == 1
      animalModel.current_spring -= 1
    else
      animalModel.current_autumn -= 1
    end
  elseif animalModel.system == 3
    if animal.calving_season == 1
      animalModel.current_b1 -= 1
    elseif animal.calving_season == 2
      animalModel.current_b2 -= 1
    elseif animal.calving_season == 3
      animalModel.current_b3 -= 1  
    elseif animal.calving_season == 4
      animalModel.current_b4 -= 1
    end
  end
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
    animalModel.current_lactating <= animalModel.optimal_lactating*rand(animalModel.rng, 0.9:0.01:1.1) && return
    do_culls!(animal, animalModel)
end

function milking!(animalModel)
  for i in 1:2
    milkers = findall(x-> x.stage == 5, animalModel.animals)
    buddies = Array{Int}(undef,2)
    for milker in milkers
      transmitter = animalModel.animals[milker]
      transmitter.processed == true && continue   
      transmitter.status ∉ [1,2,5,6,7,8] && continue
      transmitter.clinical == false && rand(animalModel.rng) < 0.5 && continue

      buddies = sample(milkers,rand(0:2))
      while milker in buddies
        buddies = sample(milkers,rand(0:2))
      end
      for bud in buddies
        atrisk = animalModel.animals[bud]
        atrisk.status ∉ [0,7,8] && continue
        rand(animalModel.rng) > atrisk.susceptibility && continue
        (transmitter.status % 2 == 0 && (transmitter.pop_r < rand(animalModel.rng))) && continue
        (transmitter.status % 2 != 0 && (transmitter.pop_p < rand(animalModel.rng))) && continue
        rand(animalModel.rng) < rand(0.01:0.05) ? atrisk.clinical = true : atrisk.clinical = false
        transmitter.status % 2 == 0 ? atrisk.status = 4 : atrisk.status = 3
        atrisk.days_exposed = 1
        atrisk.bacteriaSubmodel.total_status = atrisk.status
        atrisk.bacteriaSubmodel.clinical = atrisk.clinical
        bact_step!(atrisk.bacteriaSubmodel)
        #@info "Infection at milking"
        record_transmission!(animalModel, atrisk.id, atrisk.stage, transmitter.status, atrisk.status, :mm)

      end
    end
  end


end

"""
cull_split!(animal, animalModel)
Cull for split systems (system 1)
"""

  function cull_split!(animal, animalModel)
    animalModel.system != 2 && return
    animal.stage!= 5 && return
    (animalModel.current_autumn + animalModel.current_spring) < animalModel.optimal_lactating*rand(animalModel.rng, 0.9:0.01:1.1) && return
    if animalModel.current_spring > animalModel.optimal_spring
        animal.calving_season != 1 && return
        do_culls!(animal, animalModel)
        #@info "Spring cull"
    elseif animalModel.current_autumn > animalModel.optimal_autumn
        animal.calving_season != 2 && return
        do_culls!(animal, animalModel)
        #@info "Autumn cull"
    #= elseif (animalModel.current_autumn + animalModel.current_spring) > animalModel.optimal_lactating
        #if animal.carryover == true 
          do_culls!(animal, animalModel)
          @info "General cull"
        #end =#
    end
end

function cull_batch!(animal, animalModel)
  #animal in findall(x-> isdefined(animalModel.sending,x), 1:length(animalModel.sending)) && return
  animalModel.system != 3 && return
  animal.stage!= 5 && return
  (animalModel.current_b1 + animalModel.current_b2 + animalModel.current_b3 + animalModel.current_b4) < animalModel.optimal_lactating*(rand(animalModel.rng, 0.9:0.01:1.1)) && return
  if animalModel.current_b1 > animalModel.optimal_b1
      animal.calving_season != 1 && return
      do_culls!(animal, animalModel)
      #@info "b1 cull"
  elseif animalModel.current_b2 > animalModel.optimal_b2
      animal.calving_season != 2 && return
      do_culls!(animal, animalModel)
      #@info "b2 cull"
  elseif animalModel.current_b3 > animalModel.optimal_b3
      animal.calving_season != 3 && return
      do_culls!(animal, animalModel)
      #@info "b3 cull"
    elseif animalModel.current_b4 > animalModel.optimal_b4
      animal.calving_season != 4 && return
      do_culls!(animal, animalModel)
      #@info "b4 cull"
  end
end

"""
calving!(animal, animalModel)
Calve cows, create calf.
"""

  function calving!(animal, animalModel)
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
        animalModel.pen_counter += 1
        id = Int(animalModel.id_counter)
        stage = 1
        pos = animal.pos
        push!(animalModel.positions, pos)
        status = 0
        days_infected = 0
        days_exposed = (status == 3 || status == 4) ? Int(1) : Int(0)
        days_carrier = Int(0)
        days_recovered = Int(0)
        days_treated = Int(0)
        treatment = false

        seed = animalModel.seed
        bacteriaSubmodel = initialiseBacteria(animalno = Int(id), nbact = Int(33*33), total_status = Int(status), days_treated = Int(days_treated), days_exposed = Int(days_exposed), days_recovered = Int(days_recovered), stress = false, seed = Int(seed))
        bacteriaSubmodel.rng = MersenneTwister(id)
        pop_p = bacteriaSubmodel.pop_p
        pop_d = bacteriaSubmodel.pop_d
        pop_r = bacteriaSubmodel.pop_r
        dic = 0
        dim = 0
        stress = false
        sex = rand(animalModel.rng) > 0.5 ? 1 : 0
        calving_season = animal.calving_season
        age = Int(1)
        lactation = 0
        pregstat = 0
        trade_status = 0#false
        neighbours = get_neighbours_animal(pos)
        processed = true
        carryover = false
        fpt = rand(animalModel.rng) < animalModel.fpt_rate ? true : false
        vaccinated = animal.vaccinated
        susceptibility = fpt == true ? rand(animalModel.rng, 0.9:0.01: 1.0) : animal.status != 0 ? rand(0.35:0.01:0.45) : rand(0.55:0.01:0.65)
        clinical = false
        pen = 0
        animal = AnimalAgent(id, pos, status, stage, days_infected, days_exposed, days_carrier, days_recovered, days_treated, treatment, pop_p, pop_d, pop_r, bacteriaSubmodel, dic, dim, stress, sex, calving_season, age, lactation, pregstat, trade_status, neighbours, processed, carryover, fpt, vaccinated, susceptibility, clinical, pen)    
        environmental_transmission!(animal, animalModel)
        move_calf!(animal, animalModel)
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
end

"""
join_split!(animal, animalModel)
"""
function join_split!(animal, animalModel)
 # (animalModel.date != (animalModel.msd + Month(3))) || (animalModel.date != (animalModel.msd_2 + Month(3))) && return
  animal.pregstat != 0 && return
  animal.stage != 5 && return
  rand(animalModel.rng) ≤ 0.15 && return

  if animal.calving_season == 1 && (animalModel.date == (animalModel.msd + Month(3)))
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84)))) 
    animal.pregstat = 1
    #@info "Joined spring"
  elseif animal.calving_season == 2 && (animalModel.date == (animalModel.msd_2 + Month(3)))
    animal.dic =  Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
    animal.pregstat = 1
    #@info "Joined autumn"
  end
end 

"""
join_batch!(animal, animalModel)
Join animals in batch calving systems 
"""
function join_batch!(animal, animalModel)

  #(animalModel.date != animalModel.msd + Month(3)) || (animalModel.date != animalModel.msd_2 - Year(1) + Month(3)) || (animalModel.date != animalModel.msd_3 + Month(3)) || (animalModel.date != animalModel.msd_4 + Month(3)) && return
  animal.pregstat != 0 && return
  animal.stage != 5 && return
  rand(animalModel.rng) ≤ 0.15 && return

  if animal.calving_season == 1 && (animalModel.date == animalModel.msd + Month(3))
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
    animal.pregstat = 1
  elseif animal.calving_season == 2 && (animalModel.date == animalModel.msd_2 - Year(1) + Month(3))
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
    animal.pregstat = 1
  elseif animal.calving_season == 3 && (animalModel.date == animalModel.msd_3 + Month(3))
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
    animal.pregstat = 1
    #@info "Joined batch 3"
  elseif animal.calving_season == 4 && (animalModel.date == animalModel.msd_4 + Month(3))
    animal.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
    #@info "Joined batch 4"
    animal.pregstat = 1
  end

end

"""
animal_joining!(animal, animalModel)
"""

  function animal_joining!(animal, animalModel)
    animal.pregstat != 0 && return
    animal.stage != 5 && return
    if animalModel.system == 1
        join_seasonal!(animal, animalModel)
    elseif animalModel.system == 2
       join_split!(animal, animalModel)
    elseif animalModel.system == 3
      join_batch!(animal, animalModel)
    end

end

"""
animal_status!(animal)
Update the status of each animal depending on its bacterial population.
"""

  function animal_status!(animal)
    #if animal.status in [3,4] 
    if animal.status == 3 || animal.status == 4
      #animal.clinical == false && return
      if animal.pop_r ≥ 0.25
          animal.status = 2 
          animal.days_infected = 1
          animal.days_exposed = 0
      elseif animal.pop_p ≥ 0.25
          animal.status = 1
          animal.days_infected = 1
          animal.days_exposed = 0
      end
    end

   #=  if animal.status == 3 || animal.status == 4
      animal.clinical == true && return
      if animal.pop_r > 0.1
          animal.status = 2 
          animal.days_infected = 1
          animal.days_exposed = 0
      elseif animal.pop_p > 0.1
          animal.status = 1
          animal.days_infected = 1
          animal.days_exposed = 0
      end
    end =#

    if animal.status == 1 || animal.status == 2
      if animal.pop_r ≥ 0.25
        animal.status = 2
      elseif animal.pop_p ≥ 0.25
        animal.status = 1
      end
    end


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
    if animal.calving_season == 1 && (animalModel.date == (animalModel.msd + Day(42)))
        heifer_pregnancy!(animal, animalModel)
    elseif animal.calving_season == 2 && (animalModel.date == (animalModel.msd_2 + Day(42)))
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
    elseif animal.calving_season == 4 && animalModel.date == (animalModel.msd_4 + Day(42))
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
end

"""
dryoff_split!(animal, animalModel)
Dry off lactating cows in split systems
"""

  function dryoff_split!(animal, animalModel)
    animalModel.system != 2 && return
    if (animal.pregstat == 0 && animal.dim < 330) && (rand(animalModel.rng) < 0.4 && animal.carryover == false)
        animal.calving_season == 1 ? animal.calving_season = 2 : animal.calving_season = 1
        animal.carryover = true
      #  @info "Carried over"
    else
        set_dry!(animal, animalModel)
     #   @info "Dried off"
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
    end
      
    if animalModel.system == 2 || animalModel.system == 3
        if Year(animalModel.date) > Year(animalModel.msd_2)
            animalModel.msd_2 += Year(1)
        end
    end
    
  if animalModel.system == 3
        if Year(animalModel.date) > Year(animalModel.msd_3)
            animalModel.msd_3 += Year(1)
        end
  end  
    
  if animalModel.system == 3
      if Year(animalModel.date) > Year(animalModel.msd_4)
            animalModel.msd_4 += Year(1)
      end
  end
end

"""
animal_mstep!(animal, animalModel)
Update some parameters once per day
"""

  function animal_mstep!(animalModel)
    animalModel.timestep += 1
    animalModel.date += Day(1)
    update_msd!(animalModel)
    count_animals!(animalModel)
    animalData = animalModel.sim
    animal_export!(animalModel,animalData)

    if  (animalModel.date == animalModel.msd_4 + Month(3))
      #@info "b4"
    elseif (animalModel.date == animalModel.msd_3 + Month(3))
      #@info "b3"
    end
  end

"""
animal_stress!(animal,animalModel)
"""
function animal_stress!(animal, animalModel)
    if animal.dic >= 223 || animal.dim < 21 || (animal.age <= 2.5*365 && animal.stage == 5)
      animal.stress = true
      animal.status in [7,8] && return
     # animal.status == 7 || animal.status == 8 && return
      animal.susceptibility = rand(animalModel.rng, 0.65:0.01:0.75)
    else
      animal.stress = false
      animal.susceptibility = animal.vaccinated == true ? animalModel.vacc_efficacy  : animal.susceptibility
    end
  end

function trading_need!(animalModel)
 
      tradeable = findall(x-> x.trade_status == true, animalModel.animals)
      sample_size = length(tradeable) > 15 ? 15 : length(tradeable)
      animalModel.sending = sample(animalModel.animals[tradeable], sample_size, replace = false)


end

"""
animal_step!
Animal stepping function
"""

function animal_step!(animalModel)
  animalModel.sending = Array{AnimalAgent}(undef, 15)

  trading_need!(animalModel)
  
 # @info animalModel.sending

for x in 1:length(animalModel.animals)
         checkbounds(Bool, animalModel.animals, x) == false && continue   

         animal = animalModel.animals[x]
         animal.processed = false
         #Disease dynamics
            animal_treatment!(animal, animalModel)
            animal_fpt_vacc!(animal, animalModel)
            animal_stress!(animal, animalModel)
            animal_mortality!(animalModel, animal)
            animal_recovery!(animal, animalModel)
            animal_transmission!(animal, animalModel)
            animal_shedding!(animal)
            animal_susceptiblility!(animal, animalModel)
            end_treatment!(animal, animalModel)
            run_submodel!(animal)
            animal_status!(animal)
            contamination!(animal, animalModel)
            environmental_transmission!(animal, animalModel)


        #Population dynamics
            calving!(animal, animalModel)
            bobby_cull!(animal, animalModel)
            animal_wean!(animal, animalModel)
            animal_heifer!(animal, animalModel)

        #Trading dynamics
            flag_trades!(animal, animalModel)

        #Reproductive dynamics    
            animal_joining!(animal, animalModel)
            join_heifers!(animal, animalModel)
            cull_empty_heifers!(animal, animalModel)
            cull_slipped!(animal, animalModel)
            animal_dryoff!(animal, animalModel)
            cull_empty_dry!(animal, animalModel)
            if animalModel.timestep % 30 == 0
              cull_seasonal!(animal, animalModel) 
              cull_split!(animal, animalModel)
              cull_batch!(animal, animalModel)
            end


        #Movement
            animal_shuffle!(animal, animalModel)
            get_neighbours_animal(animal.pos)
            update_animal!(animalModel, animal)

           # export_alldata!(animal, animalModel, allData)
#=           if animal.stage == 1
            sus = animal.susceptibility
            ##@info "calf susceptibility is $sus"
          end =#

    end


    animalModel.contamination .= ifelse.(animalModel.contamination .!=0, animalModel.contamination.*(1 ./ animalModel.contam_time), 0)
    animalModel.contam_time .= ifelse.(animalModel.contam_time .>1, animalModel.contam_time .+=1, 0)
    milking!(animalModel)
    calfeteria!(animalModel,1)
    calfeteria!(animalModel,0)
    animal_mstep!(animalModel)
    pen = animalModel.calf_pen
    #@info "Pen is $pen"
end



"""
animal_export!(animalModel, animalData)
"""

  function animal_export!(animalModel,animalData)
    push!(animalData.id, animalModel.farmno)
    push!(animalData.timestep, animalModel.date)
    push!(animalData.pop_r, animalModel.pop_r)
    push!(animalData.pop_s, animalModel.pop_s)
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
    push!(animalData.inf_calves, count(i->((i.status == 1 || i.status == 2) && i.stage == 1), animalModel.animals))
    push!(animalData.inf_heifers, count(i->((i.status == 1 || i.status == 2) && i.stage == 3), animalModel.animals))
    push!(animalData.inf_weaned, count(i->((i.status == 1 || i.status == 2) && i.stage == 2), animalModel.animals))
    push!(animalData.inf_dh, count(i->((i.status == 1 || i.status == 2) && i.stage == 4), animalModel.animals))
    push!(animalData.inf_dry, count(i->((i.status == 1 || i.status == 2) && i.stage == 6), animalModel.animals))
    push!(animalData.inf_lac, count(i->((i.status == 1 || i.status == 2) && i.stage == 5), animalModel.animals))
    for i in 1:22
      for j in 8:30
      push!(animalData.inf_pens[i], count(i->((i.status == 1 || i.status == 2) && (i.stage == 1 && i.pen == j)), animalModel.animals))
      end
    end
    push!(animalData.clinical, count(i->((i.status == 1 || i.status == 2) && i.clinical == true), animalModel.animals))
    push!(animalData.subclinical, count(i->((i.status == 1 || i.status == 2) && i.clinical != true), animalModel.animals))
    push!(animalData.current_b1, count(i->(i.stage == 5 && i.calving_season == 1), animalModel.animals))
    push!(animalData.current_b2, count(i->(i.stage == 5 && i.calving_season == 2), animalModel.animals))
    push!(animalData.current_b3, count(i->(i.stage == 5 && i.calving_season == 3), animalModel.animals))
    push!(animalData.current_b4, count(i->(i.stage == 5 && i.calving_season == 4), animalModel.animals))

  end

# Run the model -------------------------------------------------