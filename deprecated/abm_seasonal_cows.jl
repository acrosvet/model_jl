function spring_cows!()
#Define the initial state of the system. Attributes for each animal in the system.
for n in 1:(N - num_heifers)
    # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
    pos = (rand(animalModel.rng, 1:Int(floor(6*√num_lac)), 2)..., 5)
    status = initial_status(n, init_ir, init_is) # Defined using initial status function
    age = Int(floor(rand(truncated(Rayleigh(5*365),(2*365), (8*365))))) # Defined using initial age function
    βᵣ = βᵣ 
    βₛ = βₛ
    treatment = :U #Default agent is untreated
    treatment_prob = treatment_prob
    days_treated = 0 # Default is not treated
    treatment_duration = treatment_duration #Passed argument
    bactopop_r = 0.0
    bactopop_is = 0.0
    since_tx = 0 # Default 0 
    inf_days = 0
    agenttype = :Initial
   # inf_days_ir = 0

    stage = :D #Initial stage
    dim = 0 # Defined using initial dim fn
    days_dry = 0 # Default 0
    days_exposed = 0 # Default 0 
    days_carrier = 0 # Default 0 
    trade_status = false #Eligibility for trading 
    lactation = round(age/365) - 1 #Lactation number
    pregstat = :P #Initial pregnancy status
    dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(240), 199, 290)))) #Gives a 63% ICR for this rng
    stress = false #If animal is in oestrus
    sex = :F #Sex of initial animals (always F)
    calving_season = :Spring
    days_recovered = 0
    submodel =  initialiseBacteria(
        nbact = nbact,
        total_status = status,
        timestep = 1.0,
        age = age,
        days_treated = days_treated,
        days_exposed = days_exposed,
        days_recovered = days_recovered,
        stress = false,
        animalno = 0,
        dim = dim
    )
    if isempty(pos, animalModel)
        add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
    end
end
end