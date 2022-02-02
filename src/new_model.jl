using Dates
using Random
using DataFrames
using BenchmarkTools
using Distributions
using StatsBase
using Plots

mutable struct Farm
    id::Int
    animals::DataFrame
    sim::DataFrame
    rng::MersenneTwister
    system::Int8
    msd::DataFrame
    neighbours::DataFrame
    optimals::DataFrame
    uid::Int
    varparms::DataFrame
    step::Int
    densities::Vector{Int}
    
end

include("new_bacterial.jl")

"""
initial_status!(herd_prev)
Set the initial status of farms based on the herd-level prevalence
"""

function initial_status(rng, prev_p, prev_r, prev_cp, prev_cr)
  
  if rand(rng) < prev_p
    1
  elseif rand(rng) < prev_r
    2
  elseif rand(rng) < prev_cp
    5
  elseif rand(rng) < prev_cr
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

  function get_neighbours_animal!(farm)

   # neighbour = farm.neighbours

   @. farm.neighbours.n1x .= farm.animals.x .- 1
   @. farm.neighbours.n1y .= farm.animals.y .+ 1

   @. farm.neighbours.n2x .= farm.animals.x
   @. farm.neighbours.n2y .= farm.animals.y .+ 1

   @. farm.neighbours.n3x .= farm.animals.x .+ 1
   @. farm.neighbours.n3y .= farm.animals.y .+ 1

   @. farm.neighbours.n4x .= farm.animals.x .+ 1
   @. farm.neighbours.n4y .= farm.animals.y 

   @. farm.neighbours.n5x .= farm.animals.x .+ 1
   @. farm.neighbours.n5y .= farm.animals.y .- 1

   @. farm.neighbours.n6x .= farm.animals.x
   @. farm.neighbours.n6y .= farm.animals.y .- 1

   @. farm.neighbours.n7x .= farm.animals.x .- 1
   @. farm.neighbours.n7y .= farm.animals.y .- 1

   @. farm.neighbours.n8x .= farm.animals.x .- 1
   @. farm.neighbours.n8y .= farm.animals.y 


     farm.neighbours.n1 .= vec.(hcat.(farm.neighbours.n1x, farm.neighbours.n1y, farm.neighbours.n1z))
    farm.neighbours.n2 .= vec.(hcat.(farm.neighbours.n2x, farm.neighbours.n2y, farm.neighbours.n2z))
    farm.neighbours.n3 .= vec.(hcat.(farm.neighbours.n3x, farm.neighbours.n3y, farm.neighbours.n3z))
    farm.neighbours.n4 .= vec.(hcat.(farm.neighbours.n4x, farm.neighbours.n4y, farm.neighbours.n4z))
    farm.neighbours.n6 .= vec.(hcat.(farm.neighbours.n6x, farm.neighbours.n6y, farm.neighbours.n6z))
    farm.neighbours.n5 .= vec.(hcat.(farm.neighbours.n5x, farm.neighbours.n5y, farm.neighbours.n5z))
    farm.neighbours.n7 .= vec.(hcat.(farm.neighbours.n7x, farm.neighbours.n7y, farm.neighbours.n7z))
    farm.neighbours.n8 .= vec.(hcat.(farm.neighbours.n8x, farm.neighbours.n8y, farm.neighbours.n8z))

     farm.animals.pos .= vec.(hcat.(farm.animals.x, farm.animals.y, farm.animals.z))
    
end

"""
initial_animals!
"""
function initial_animals!(farm;stockno, stage, dic, dim, age, pregstat, calving_season, prev_p, prev_r, prev_cp, prev_cr)

  animals = farm.animals
  

  for cow in 1:stockno
    farm.uid += 1
    animals.id[farm.uid] = Int16(farm.uid)
    animals.stage[farm.uid] = stage
    animals.dic[farm.uid] = eval(dic)
    animals.dim[farm.uid] = eval(dim)
    animals.age[farm.uid] = eval(age)
    animals.pregstat[farm.uid] = pregstat
    animals.calving_season[farm.uid] = calving_season
    animals.pos[farm.uid] = [rand(farm.rng, 1:Int(floor(farm.densities[stage]*√farm.optimals.optimal_lactating[1])), 2)..., stage]
    while animals.pos[farm.uid] in animals.pos == true
      animals.pos[farm.uid] = [rand(farm.rng, 1:Int(floor(farm.densities[stage]*√farm.optimals.optimal_lactating[1])), 2)..., stage]
    end
    animals.x[farm.uid] = animals.pos[farm.uid][1]
    animals.y[farm.uid] = animals.pos[farm.uid][2]
    animals.z[farm.uid] = animals.pos[farm.uid][3]
    animals.status[farm.uid] = initial_status(farm.rng, prev_p, prev_r, prev_cp, prev_cr)
    animals.days_infected[farm.uid] = animals.status[farm.uid] == 1 || animals.status[farm.uid] == 2 ? 1 : 0
    animals.days_carrier[farm.uid] = animals.status[farm.uid] == 5 || animals.status[farm.uid] == 6 ? 1 : 0
    animals.pop_d[farm.uid] = animals.pop_p[farm.uid] = animals.pop_r[farm.uid] = 0
    animals.vaccinated[farm.uid] = rand(farm.rng) < farm.varparms.vacc_rate[1] ? true : false
    animals.susceptibility[farm.uid] = animals.vaccinated[farm.uid] == true ?  farm.varparms.vacc_efficacy[1] : 0.5
    animals.bacteria[farm.uid].id = farm.uid
    animals.bacteria[farm.uid].status = animals.status[farm.uid]
    animals.bacteria[farm.uid].days_treated = animals.days_treated[farm.uid]
    animals.bacteria[farm.uid].days_exposed = animals.days_exposed[farm.uid]
    animals.bacteria[farm.uid].days_recovered = animals.days_recovered[farm.uid]
    animals.bacteria[farm.uid].stress = animals.stress[farm.uid]
    
    
    
    
    #animals.bacteria[farm.uid] = makeAnimal(id = farm.uid, step = farm.step, status = farm.animals.status[farm.uid], days_treated = farm.animals.days_treated[farm.uid], days_exposed = farm.animals.days_exposed[farm.uid], days_recovered = farm.animals.days_recovered[farm.uid], stress = false, maxdays = length(farm.sim.date), bactcolonies = 33*33 )
    #animals.bacteria[farm.uid] = initialiseBacteria(animalno = Int16(farm.uid), nbact = Int16(33*33),  status = Int8(farm.animals.status[farm.uid]), days_treated = Int8(farm.animals.days_treated[farm.uid]), days_exposed = Int8(farm.animals.days_exposed[farm.uid]), days_recovered = Int8(farm.animals.days_recovered[farm.uid]), stress = false, seed = Int8(1))
  end
end

function makeFarm(;
    id::Int = 1,
    maxanimals::Int = 5000,
    days::Int = 3653, 
    system::Int = 1,
    numlac::Int = 273,
    uid::Int = 0,
    density_lactating::Int = 6,
    density_calves::Int = 3,
    density_dry::Int = 7,
    prev_p::Float32 = Float32(0.01),
    prev_r::Float32 = Float32(0.01),
    prev_cr::Float32 = Float32(0.04),
    prev_cp::Float32 = Float32(0.04),
    vacc_rate::Float32 = Float32(0.0),
    vacc_efficacy::Float32 = Float32(0.1),
    fpt_rate::Float32 = Float32(0.0),
    treatment_prob::Float32 = Float32(0.5),
    carrier_prob::Float32 = Float32(0.05),
    treatment_length::Int = 5
        )

    rng = MersenneTwister(id)

    animal = makeAnimal()

    densities = [density_calves, density_dry, density_dry, density_dry, density_lactating, density_dry]


    animals = DataFrame(
        id = fill(0, maxanimals),
        day = fill(0, maxanimals),
        bernoulli = Vector{Union{Float32, Nothing}}(nothing, maxanimals),
        date = Date(2021,7,2),
        x = fill(0, maxanimals),
        y = fill(0, maxanimals),
        z = fill(0, maxanimals),
        pos = fill([0,0,0], maxanimals),
        status =  fill(-1, maxanimals),
        stage =  fill(-1, maxanimals),
        days_infected =  fill(-1, maxanimals),
        days_exposed =  fill(-1, maxanimals),
        days_carrier = fill(-1, maxanimals),
        days_treated =  fill(-1, maxanimals),
        days_recovered =  fill(-1, maxanimals),
        treatment =   fill(false,maxanimals),
        
        pop_p =  fill(0.0,maxanimals),
        pop_d =   fill(0.0,maxanimals),
        pop_r =   fill(0.0,maxanimals),
        dic =   fill(-1, maxanimals),
        dim =   fill(-1, maxanimals),
        sex =   Vector{Union{Nothing, Int}}(nothing,maxanimals),
        calving_season =   fill(-1, maxanimals),
        age =   fill(-1, maxanimals),

       # lactation =   Vector{Union{Nothing, Int}}(nothing,maxanimals),
        pregstat =   fill(-1, maxanimals),
        trade_status =   Vector{Union{Nothing, Int}}(nothing,maxanimals),
       
        processed = Vector{Union{Nothing, Bool}}(nothing,maxanimals),
        carryover = Vector{Union{Nothing, Bool}}(nothing,maxanimals),
        fpt = Vector{Union{Nothing, Bool}}(nothing,maxanimals),
        vaccinated = Vector{Union{Nothing, Bool}}(nothing,maxanimals),
        susceptibility = Vector{Union{Nothing, Float32}}(nothing,maxanimals),
        cullpoint = fill(0, maxanimals),
        cullflag = fill(false, maxanimals),
        bacteria = fill(animal, maxanimals),

        neighbours = fill([0,0,0,0,0,0,0,0], maxanimals)
    )

    @. animals.cullpoint =  Int(floor(rand(truncated(Rayleigh(7*365), 5*365, 7*365))))
    
    neighbours = DataFrame(
      n1x = fill(0, maxanimals),
      n1y = fill(0, maxanimals),
      n1z = fill(0, maxanimals),
      n2x = fill(0, maxanimals),
      n2y = fill(0, maxanimals),
      n2z = fill(0, maxanimals),
      n3x = fill(0, maxanimals),
      n3y = fill(0, maxanimals),
      n3z = fill(0, maxanimals),
      n4x = fill(0, maxanimals),
      n4y = fill(0, maxanimals),
      n4z = fill(0, maxanimals),
      n5x = fill(0, maxanimals),
      n5y = fill(0, maxanimals),
      n5z = fill(0, maxanimals),
      n6x = fill(0, maxanimals),
      n6y = fill(0, maxanimals),
      n6z = fill(0, maxanimals),
      n7x = fill(0, maxanimals),
      n7y = fill(0, maxanimals),
      n7z = fill(0, maxanimals),
      n8x = fill(0, maxanimals),
      n8y = fill(0, maxanimals),
      n8z = fill(0, maxanimals),
      n1 = fill([0,0,0], maxanimals),
      n2 = fill([0,0,0], maxanimals),
      n3 = fill([0,0,0], maxanimals),
      n4 = fill([0,0,0], maxanimals),
      n5 = fill([0,0,0], maxanimals),
      n6 = fill([0,0,0], maxanimals),
      n7 = fill([0,0,0], maxanimals),
      n8 = fill([0,0,0], maxanimals)
    )

    msd = DataFrame(
        msd = [Date(2021,9,24)],
        msd_2 = Date(2021,9,24) + Month(3),
        msd_3 = Date(2021,9,24) - Month(6),
        msd_4 = Date(2021,9,24) - Month(3)
    )

    optimals = DataFrame(
        optimal_lactating = numlac,
        optimal_heifers = Int(floor(0.3*numlac)),
        optimal_spring = Int(floor(0.5*numlac)),
        optimal_autumn = Int(floor(0.5*numlac)),
        optimal_weaned = Int(floor(0.3*numlac))

    )



    varparms = DataFrame(
      vacc_rate = vacc_rate,
      vacc_efficacy = vacc_efficacy,
      fpt_rate = fpt_rate,
      treatment_prob = treatment_prob,
      treatment_length = treatment_length,
      carrier_prob = carrier_prob
    )

    sim = DataFrame(
    timestep = [1:1:days;],
    date = [Date(2021,7,2):Day(1):Date(2021,7,1) + Day(days);],
    sending = Vector{Union{Vector{Int}, Nothing}}(nothing, days),
    receiving = Vector{Union{Vector{Int}, Nothing}}(nothing, days),
    tradeable_stock = Vector{Int}(undef, days),
    pop_r = zeros(days),
    pop_p = zeros(days),
    pop_s = zeros(days),
    pop_d = zeros(days),
    current_dry =zeros(days),
    current_calves = zeros(days),
    current_weaned = zeros(days),
    current_lactating =zeros(days),
    current_dh = zeros(days),
    current_heifers = zeros(days),
    surplus_spring = zeros(days)
    )

    step = 0

   farm =  Farm(id, animals, sim, rng, system, msd, neighbours, optimals, uid, varparms, step, densities) 
   

   farm.animals.day .= 1
   farm.animals.bernoulli .= rand.(farm.rng)
   farm.animals.days_exposed .= 0
   farm.animals.days_treated .= 0
   farm.animals.days_recovered .= 0
   farm.animals.treatment .= false
   farm.animals.stress .= false
   farm.animals.sex .= 1
   farm.animals.trade_status .= 0
   farm.animals.carryover .= false
   farm.animals.fpt .= false
    

   stocktype  = [:dry, :heifers, :weaned ]
   all_stockno = [farm.optimals.optimal_lactating[1] - farm.optimals.optimal_heifers[1], farm.optimals.optimal_heifers[1], farm.optimals.optimal_weaned[1]]
   stages = [6, 4, 2]
   all_dim = [0, 0, 0]
   all_dic = [Meta.parse("floor(rand(truncated(Rayleigh(240), 199, 280)))"), Meta.parse("floor(rand(truncated(Rayleigh(240), 199, 280)))"), 0 ]
   all_age = [Meta.parse("floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))"), Meta.parse("floor(rand(truncated(Rayleigh(2*365),(22*30), (25*30))))"),  Meta.parse("floor(rand(truncated(Rayleigh(365),(295), (395))))") ]
   all_pregstat = [1, 1, 0]
   all_seasons = [0, 0, 0]

   for i in 1:length(stocktype)
       initial_animals!(
         farm,
           stockno = all_stockno[i],
           stage = stages[i], 
           dic = all_dic[i],
           dim = all_dim[i],
           age = all_age[i],
           pregstat = all_pregstat[i],
           calving_season = all_seasons[i],
           prev_p = prev_p,
           prev_r = prev_r,
           prev_cp = prev_cp,
           prev_cr = prev_cr
       )
   end

    #Set initial neighbours

    farm.neighbours.n1x .= farm.animals.x .-1
    farm.neighbours.n1y .= farm.animals.y .+ 1
    farm.neighbours.n1z .= farm.animals.z .- 0
    
    farm.neighbours.n2x .= farm.animals.x .-0
    farm.neighbours.n2y .= farm.animals.y .+ 1
    farm.neighbours.n2z .= farm.animals.z 

    farm.neighbours.n3x .= farm.animals.x .+ 1 
    farm.neighbours.n3y .= farm.animals.y .+ 1
    farm.neighbours.n3z .= farm.animals.z 


    farm.neighbours.n4x .= farm.animals.x .+1
    farm.neighbours.n4y .= farm.animals.y 
    farm.neighbours.n4z .= farm.animals.z 

    farm.neighbours.n5x .= farm.animals.x .+ 1
    farm.neighbours.n5y .= farm.animals.y .- 1
    farm.neighbours.n5z .= farm.animals.z 

    farm.neighbours.n6x .= farm.animals.x 
    farm.neighbours.n6y .= farm.animals.y .- 1
    farm.neighbours.n6z .= farm.animals.z 

    farm.neighbours.n7x .= farm.animals.x .-1
    farm.neighbours.n7y .= farm.animals.y .- 1
    farm.neighbours.n7z .= farm.animals.z 

    farm.neighbours.n8x .= farm.animals.x .-1
    farm.neighbours.n8y .= farm.animals.y 
    farm.neighbours.n8z .= farm.animals.z 

    
    return farm
    
end

increment(x) = x > 0 ? x + 1 : x

"""
update_animal!(animalModel)
Increment animal parameters
"""

  function update_animal!(farm)

  
   farm.step += 1
   farm.animals.date .+= Day(1)

   animals = findall(farm.animals.id .!= 0 .&& farm.animals.stage .!= 10)

    for animal in animals
    farm.animals.bacteria[animal].days_exposed = farm.animals.days_exposed[animal]
    farm.animals.bacteria[animal].days_carrier = farm.animals.days_carrier[animal]
    farm.animals.bacteria[animal].days_treated = farm.animals.days_treated[animal]
    farm.animals.bacteria[animal].days_recovered = farm.animals.days_recovered[animal]
    farm.animals.pop_r[animal] = farm.animals.bacteria[animal].pop_r
    farm.animals.pop_p[animal] = farm.animals.bacteria[animal].pop_p
   end 


   foreach(col -> col .= increment.(col), eachcol(farm.animals[!, [:dic, :dim, :days_infected, :days_treated, :days_carrier, :days_exposed, :days_recovered, :age, :day]]))


   if Year(farm.sim.date[farm.step]) > Year(farm.msd.msd[1])
      farm.msd.msd[1] += Year(1)
   end

  farm.animals.bernoulli .= rand.(farm.rng)
end

count_status!(col, status) = sum(col .== status)

function count_animals!(farm)

   farm.sim.pop_p[farm.step] = count_status!(farm.animals.status, 1)
   farm.sim.pop_r[farm.step] = count_status!(farm.animals.status, 2)
   farm.sim.pop_s[farm.step] = count_status!(farm.animals.status, 0)
   farm.sim.pop_d[farm.step] = count_status!(farm.animals.status, 10)
   
   farm.sim.current_calves[farm.step] = count_status!(farm.animals.stage, 1)
   farm.sim.current_weaned[farm.step] = count_status!(farm.animals.stage, 2)
   farm.sim.current_heifers[farm.step] = count_status!(farm.animals.stage, 3)
   farm.sim.current_dh[farm.step] = count_status!(farm.animals.stage, 4)
   farm.sim.current_lactating[farm.step] = count_status!(farm.animals.stage, 5)
   farm.sim.current_dry[farm.step] = count_status!(farm.animals.stage, 6)

   farm.sim.surplus_spring[farm.step] = farm.sim.current_lactating[farm.step] - farm.optimals.optimal_lactating[1]

#@btime statuses = countmap(farm.animals.status)

end

"""
culls
"""
function culls!(farm)
  
  farm.animals.cullflag .== false 
# Define culling eligibility

  

    do_cull!.(Ref(farm), findall(farm.animals.stage .== 6 .&& farm.animals.pregstat .== 0))


    do_cull!.(Ref(farm), findall(farm.animals.stage .== 3 .&& farm.animals.pregstat .== 0 .&& farm.animals.age .≥ 559))


    do_cull!.(Ref(farm), findall(farm.animals.stage .== 1 .&& farm.animals.sex .== 0 .&& farm.animals.age .≥ 6))

    do_cull!.(Ref(farm), findall(farm.animals.dim .>= 280 .&& farm.animals.dic .<= 150))

    do_cull!.(Ref(farm), findall(farm.animals.age .>= 9*365))


    age_cull = findall(farm.animals.age .>  Int(floor(rand(truncated(Rayleigh(7*365), 5*365, 7*365)))))
    farm.step == 1 && return
    surplus = Int(floor(farm.sim.surplus_spring[farm.step-1]))
    #println(surplus)
    if surplus > 0 
      surplus = surplus > length(age_cull) ? length(age_cull) : surplus
      age_cull = findall(farm.animals.age .> farm.animals.cullpoint)[1:surplus]
     # println(age_cull)
      do_cull!.(Ref(farm), age_cull)
     # println("Age cull")
    end
      
end

function stress!(farm)

  stressed = vcat(findall(farm.animals.dic .>= 223), findall(farm.animals.age .<= 21 .&& farm.animals.age .> 0), findall(farm.animals.age .<= 2.5*365 .&& farm.animals.stage .== 5))
#=   springers = findall(farm.animals.dic .>= 223)
  calves = findall(farm.animals.age .<= 21 .&& farm.animals.age .> 0) 
  fresh = findall(farm.animals.age .<= 2.5*365 .&& farm.animals.stage .== 5) =#


  farm.animals.stress[stressed] .= true 

  notcarrier = findall(farm.animals.status[stressed] .!= 7 .|| farm.animals.status[stressed] .!= 8)

  farm.animals.susceptibility[notcarrier] = rand(farm.rng, 0.05:0.01:0.55, length(notcarrier))

  unstressed = farm.animals.id[(!in).(farm.animals.id,Ref(stressed))]
  filter!(x-> x!=0, unstressed)

  farm.animals.stress[unstressed] .= false

    for i in unstressed
   farm.animals.susceptibility[i] =  farm.animals.vaccinated[i] == true ?  farm.varparms.vacc_efficacy[1] : farm.animals.susceptibility[i]
  end
  
end


function spring_cull!(farm, inds)
  farm.step == 1 && return
  farm.system != 1 && return
  farm.sim.surplus_spring[farm.step] <= 0 && return
  length(inds) == 0 && return
  
  if length(inds) <= farm.sim.surplus_spring[farm.step]
       for i in 1:length(inds)
      do_cull!(farm, inds[i])
    end
  else
    inds = inds[1:Int(farm.sim.surplus_spring[farm.step])]
      for i in 1:length(inds)
      do_cull!(farm, inds[i])
      #farm.animals.stage[inds[i]] = 10
    end
  end

end

function split_cull!(farm, inds)
  farm.system != 2 && return
  farm.sim.surplus_spring[farm.step] <= 0 || farm.sim.surplus_autumn[farm.step] <= 0 && return
  length(inds) == 0 && return
  
  if length(inds) ≤ farm.sim.surplus_spring[farm.step] 
    [do_cull!(farm, inds[i]) for i in 1:length(inds)]
  else
    inds = inds[1:farm.sim.surplus_spring[farm.step]]
    [do_cull!(farm, inds[i]) for i in 1:length(inds)]
  end

  if length(inds) ≤ farm.sim.surplus_autumn[farm.step] 
    [do_cull!(farm, inds[i]) for i in 1:length(inds)]
  else
    inds = inds[1:farm.sim.surplus_autumn[farm.step]]
    [do_cull!(farm, inds[i]) for i in 1:length(inds)]
  end

end

function do_cull!(farm, index)
  farm.animals.stage[index] = 10
  farm.animals.x[index] = farm.animals.y[index] = farm.animals.z[index] = 10
  farm.animals.pos[index] = [10,10,10]
  farm.animals.dic[index] = farm.animals.dim[index] = farm.animals.status[index] = farm.animals.days_infected[index] = farm.animals.days_recovered[index] = -10
end


function end_treatment!(farm)
  finishedcourse = findall(farm.animals.treatment .== true .&& farm.animals.days_treated .> farm.varparms.treatment_length[1])

  farm.animals.treatment[finishedcourse] .= false
  farm.animals.days_treated[finishedcourse] .= 0
  
    for finished in finishedcourse
    farm.animals.bacteria[finished].days_treated = 0
  end


end

function calving!(farm)
  pregs = findall(farm.animals.dic .== 283)

  isempty(pregs) && return
 # farm.sim.current_lactating[farm.step] = length(pregs)

  farm.animals.stage[pregs] = farm.animals.z[pregs] .= 5
  farm.animals.dim[pregs] .= 1
  farm.animals.dic[pregs] = farm.animals.pregstat[pregs] .= 0
  farm.animals.carryover[pregs] .= false


  #Move the dry into the lactating plane
  
    for i in 1:length(pregs)
      farm.animals.x[pregs] = sample(1:Int(floor(sqrt(farm.densities[5]*length(pregs)))), length(pregs))
      farm.animals.y[pregs] = sample(1:Int(floor(sqrt(farm.densities[5]*length(pregs)))), length(pregs))
      farm.animals.z[pregs] .= 5
  end

 # println(pregs)
  #Create the calves 

    for i in 1:length(pregs)
    farm.uid += 1
    dam = farm.animals.id[pregs[i]]
    farm.animals.id[farm.uid] = farm.uid
    farm.sim.current_calves[farm.step] += 1
    farm.animals.stage[farm.uid] = farm.animals.age[farm.uid] = 1
    farm.animals.x[farm.uid] = rand(1:Int(floor(farm.densities[1]*√length(farm.sim.current_calves[farm.step]))))
    farm.animals.y[farm.uid]= rand(1:Int(floor(farm.densities[1]*√length(farm.sim.current_calves[farm.step]))))
    farm.animals.z[farm.uid] = 1
    farm.animals.status[farm.uid] = (farm.animals.status[dam] == 1 || farm.animals.status[dam] == 2) ? (farm.animals.status[dam] == 1  ? 3 : 4) : 0
    farm.animals.days_exposed[farm.uid] = (farm.animals.status[farm.uid] == 3 || farm.animals.status[farm.uid] == 4) ? 1 : 0
    farm.animals.days_carrier[farm.uid] = farm.animals.days_recovered[farm.uid] = farm.animals.days_treated[farm.uid] = 0
    farm.animals.treatment[farm.uid] = farm.animals.carryover[farm.uid] = false
    farm.animals.sex[farm.uid] = rand(farm.rng) > 0.5 ? 1 : 0
    farm.animals.calving_season[farm.uid] = farm.animals.calving_season[dam]
    farm.animals.days_carrier[farm.uid] = farm.animals.pregstat[farm.uid] = farm.animals.trade_status[farm.uid] = 0
    farm.animals.fpt[farm.uid] = rand(farm.rng) < farm.varparms.fpt_rate[1] ? true : false
    farm.animals.vaccinated[farm.uid] = false
    farm.animals.susceptibility[farm.uid] = farm.animals.fpt[farm.uid] == true ? rand(farm.rng, 0.9:0.01: 1.0) : 0.5
    farm.animals.bacteria[farm.uid].id = farm.uid
    farm.animals.bacteria[farm.uid].status = farm.animals.status[farm.uid]
    farm.animals.bacteria[farm.uid].days_treated = farm.animals.days_treated[farm.uid]
    farm.animals.bacteria[farm.uid].days_exposed = farm.animals.days_exposed[farm.uid]
    farm.animals.bacteria[farm.uid].days_recovered = farm.animals.days_recovered[farm.uid]
    farm.animals.bacteria[farm.uid].stress = farm.animals.stress[farm.uid]
  end

end

function reshuffle!(farm)
 
  animals = Vector{Vector{Int}}(undef, 6)

    for i in 1:length(animals)
    animals[i] = findall(farm.animals.stage .== i)
  end

  
    for i in 1:length(animals)
    isempty(animals[i]) && continue
    farm.animals.x[animals[i]] = sample(1:Int(floor(sqrt(farm.densities[i]*length(animals[i])))), length(animals[i]))
    farm.animals.y[animals[i]] = sample(1:Int(floor(sqrt(farm.densities[i]*length(animals[i])))), length(animals[i]))
    farm.animals.z[animals[i]]  .= i
  end

  farm.animals.pos .= vec.(hcat.(farm.animals.x, farm.animals.y, farm.animals.z))

end

function join_seasonal!(farm)
  farm.sim.date[farm.step] != (farm.msd.msd[1] + Month(3)) && return
  pregs = findall(farm.animals.pregstat .== 0 .&& farm.animals.stage .== 5)
  pregs = pregs[1:Int(floor(0.78*length(pregs)))]
  farm.animals.pregstat[pregs] .= 1
  farm.animals.dic[pregs] = floor.(Int, rand(farm.rng, truncated(Rayleigh(63), 1, 93), length(pregs)))
   
end

function wean!(farm)
  calves = findall(farm.animals.stage .== 1 .&& farm.animals.age .>= 60)
  isempty(calves) && return
  #Keep
    surplus = Int(floor(farm.sim.current_weaned[farm.step-1] - farm.optimals.optimal_weaned[1]))
    #println(surplus)
    if surplus <= 0
      keep = calves[1:Int(floor(length(calves)))]
      farm.animals.x[keep] = sample(1:Int(floor(sqrt(farm.densities[2]*length(keep)))), length(keep))
      farm.animals.y[keep] = sample(1:Int(floor(sqrt(farm.densities[2]*length(keep)))), length(keep))
      farm.animals.z[keep] = farm.animals.stage[keep] .= 2
    else 
      surplus = surplus >= length(calves) ? length(calves) : surplus
      do_cull!.(Ref(farm), surplus)
    end


    #surplus = findall(farm.animals.stage .== 1 .&& farm.animals.age .>= 60)


end

function contact_tracer!(transmitter, farm)
  farm.animals.neighbours[transmitter][1] = findfirst(isequal(farm.neighbours.n1[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n1[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][2] = findfirst(isequal(farm.neighbours.n2[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n2[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][3] = findfirst(isequal(farm.neighbours.n3[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n3[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][4] = findfirst(isequal(farm.neighbours.n4[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n4[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][5] = findfirst(isequal(farm.neighbours.n5[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n5[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][6] = findfirst(isequal(farm.neighbours.n6[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n6[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][7] = findfirst(isequal(farm.neighbours.n7[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n7[transmitter]), farm.animals.pos)
  farm.animals.neighbours[transmitter][8] = findfirst(isequal(farm.neighbours.n8[transmitter]), farm.animals.pos) === nothing ? 0 : findfirst(isequal(farm.neighbours.n8[transmitter]), farm.animals.pos)
end



function animal_transmission!(farm)

  transmitters = findall((farm.animals.status .== 1 .|| farm.animals.status .== 2) .|| (farm.animals.status .>= 5 .&& farm.animals.status .<= 8))

  Threads.@threads for transmitter in transmitters
    contact_tracer!(transmitter, farm)
    for contact in farm.animals.neighbours[transmitter]
        contact == 0 && continue
        farm.animals.status[contact] ∉ [0,7,8] && continue
        farm.animals.bernoulli[transmitter] < farm.animals.susceptibility[contact] && continue
       # println("transmission")
        farm.animals.status[transmitter] % 2 == 0 ? farm.animals.status[contact] = 4 : farm.animals.status[contact] = 3
        farm.animals.status[transmitter] % 2 == 0 ? farm.animals.bacteria[contact]. status = 4 : farm.animals.bacteria[contact]. status = 3
        farm.animals.days_exposed[contact] = 1
        farm.animals.bacteria[contact].days_exposed = 1
    end
  end

end

function shed!(farm)

  shedders = findall((farm.animals.status .== 5 .|| farm.animals.status .== 6) .&& farm.animals.stress .== true)

    for shedder in shedders
      farm.animals.bacteria[shedder].days_exposed = 1
      farm.animals.status[shedder] % 2 == 0 ? farm.animals.bacteria[shedder]. status = 4 : farm.animals.bacteria[shedder]. status = 3
  end

  notshedders = findall((farm.animals.status .== 5 .|| farm.animals.status .== 6) .&& farm.animals.stress .== false)

    for notshedder in notshedders
    farm.animals.bacteria[notshedder].days_exposed = 0
    farm.animals.bacteria[notshedder].days_carrier = 0
  end

end

function susceptible!(farm)
  susceptibles = findall(farm.animals.status .== 7 .|| farm.animals.status .== 8)

    for susceptible in susceptibles
    farm.animals.susceptibility[susceptible] = ℯ^(-300/farm.animals.days_recovered[susceptible])
    farm.animals.susceptibility[susceptible] ≥ 0.5 ? farm.animals.status[susceptible] = 0 : continue
  end

end

function heifers!(farm)

  heifers = findall(farm.animals.stage .== 2 .&& farm.animals.age .== 13*30)

  
  farm.animals.x[heifers] = sample(1:Int(floor(sqrt(farm.densities[3]*length(heifers)))), length(heifers))
  farm.animals.y[heifers] = sample(1:Int(floor(sqrt(farm.densities[3]*length(heifers)))), length(heifers))
  farm.animals.z[heifers] = farm.animals.stage[heifers] .= 3

end

function join_heifers!(farm)
  if farm.system == 1
    farm.sim.date[farm.step] != (farm.msd.msd[1] + Day(42)) && return
    heifers = findall(farm.animals.stage .== 3)
    isempty(heifers) && return
    keep = heifers[1:Int(floor(0.85*length(heifers)))]
    heifer_pregnancy!(farm, keep)
    surplus = findall(farm.animals.stage .== 3)
    do_cull!.(Ref(farm), surplus)
  end
end

function heifer_pregnancy!(farm, heifers)
  farm.animals.pregstat[heifers] .= 1
  farm.animals.stage[heifers] .= 4
  farm.animals.dic[heifers] = floor.(Int, rand(farm.rng, truncated(Rayleigh(42), 1, 63), length(heifers)))
end

function set_dry!(farm, dryoffs)

  farm.animals.stage[dryoffs] .= 6
  farm.animals.dim[dryoffs] .= 0
  farm.animals.x[dryoffs] = sample(1:Int(floor(sqrt(farm.densities[6]*length(dryoffs)))), length(dryoffs))
  farm.animals.y[dryoffs] = sample(1:Int(floor(sqrt(farm.densities[6]*length(dryoffs)))), length(dryoffs))
  farm.animals.z[dryoffs] = farm.animals.stage[dryoffs] .= 6

end

function  run_submodel!(farm)
subs = findall( farm.animals.stage .!= 10 .&& farm.animals.status .> 0)
for sub in subs
  #animal_step!(farm.animals.bacteria[sub])
end


end 
  
function dryoff!(farm)
  if farm.system == 1 
    dryoffs = findall(farm.animals.dim .== 305)
    set_dry!(farm, dryoffs)
  end
end

function treatment!(farm)

  treatme = findall((farm.animals.status .== 1 .|| farm.animals.status .== 2) .&& farm.animals.treatment .== false)

    for treatment in treatme
    farm.animals.bernoulli[treatment] > farm.varparms.treatment_prob[1] && continue
    #println(treatment)
    farm.animals.days_treated[treatment] = 1
    farm.animals.treatment[treatment] = true
    farm.animals.bacteria[treatment].days_treated = 1
  end


end

function status!(farm)
  exposures = findall(farm.animals.status .== 3 .|| farm.animals.status .== 4)

    for exposed in exposures
    if farm.animals.pop_r[exposed] ≥ 0.5
      farm.animals.status[exposed] = 2
      farm.animals.days_infected[exposed] = 1
      farm.animals.days_exposed[exposed] = 0
    elseif farm.animals.pop_p[exposed] >= 0.5
      farm.animals.status[exposed] = 1
      farm.animals.days_infected[exposed] = 1
      farm.animals.days_exposed[exposed] = 0
    end
  end

  infections = findall(farm.animals.status .== 1 .|| farm.animals.status .== 2)

    for infection in infections
    if farm.animals.pop_r[infection] >=  0.5
      farm.animals.status[infection] = 2
    elseif farm.animals.pop_p[infection] ≥ 0.5
      farm.animals.status[infection] = 1
    end
  end
end

function recovery!(farm)

  recoveries = findall((farm.animals.status .== 1 .|| farm.animals.status .== 2) .&& farm.animals.days_infected .> 0)

    for recover in recoveries
    farm.animals.days_infected[recover] < rand(farm.rng, 5:7) && continue
    farm.animals.days_infected[recover] = 0
    farm.animals.days_recovered[recover] = 1  
    if farm.animals.bernoulli[recover] < farm.varparms.carrier_prob[1]
      farm.animals.status[recover] % 2 == 0 ? farm.animals.status[recover] = 6 : farm.animals.status[recover] = 5
      farm.animals.status[recover] % 2 == 0 ? farm.animals.bacteria[recover]. status = 8 : farm.animals.bacteria[recover]. status = 7
    else
      farm.animals.status[recover] % 2 == 0 ? farm.animals.status[recover] = 6 : farm.animals.status[recover] = 5
      farm.animals.status[recover] % 2 == 0 ? farm.animals.bacteria[recover]. status = 8 : farm.animals.bacteria[recover]. status = 7
    end
  end

end

function fpt_vacc!(farm)

  fpts = findall(farm.animals.fpt .== true .&& farm.animals.age .< 60)

  farm.animals.fpt[fpts] = sample(0.9:0.01:1.0, length(fpts))

  vaccinates = findall(farm.animals.age .== 60 .&& farm.animals.bernoulli .< farm.varparms.vacc_rate[1])
  farm.animals.vaccinated[vaccinates] .= true
  farm.animals.susceptibility[vaccinates] .= farm.varparms.vacc_efficacy[1]

end

function farm_step!(farm)
 # farm.animals[shuffle(axes(farm.animals, 1)), :]
  update_animal!(farm)
  
  calving!(farm)
  fpt_vacc!(farm)
  join_seasonal!(farm)  
  culls!(farm)
  wean!(farm)
  heifers!(farm)
  join_heifers!(farm)
  dryoff!(farm)
  stress!(farm)
  shed!(farm)
  treatment!(farm)
  end_treatment!(farm)
  recovery!(farm)


  
  reshuffle!(farm)
  get_neighbours_animal!(farm)

  animal_transmission!(farm)

  status!(farm)
 # run_submodel!(farm)


  count_animals!(farm)


end

farm = makeFarm()
@time farm_step!(farm)

 function runfarm!(farm)
    [farm_step!(farm) for i in 1:3640]
end

@time runfarm!(farm)

plot(farm.sim.current_lactating, labels = "Lactating")
plot!(farm.sim.current_calves, labels = "Calves")
plot!(farm.sim.current_dry, labels = "Dry")
plot!(farm.sim.current_heifers, labels = "Heifers")
plot!(farm.sim.current_dh, labels = "DH")


 Plots.scatter3d(farm.animals.x, farm.animals.y, farm.animals.z)
