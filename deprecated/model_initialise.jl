  
#Define model initialisation functions. 

function initialiseModel(
    N = 60, #Default number of animals
    seed = 42, #Random seed
    calfProximityRadius = 0.5, #Radius for effective contact
    mortalityRateSens = 0.01/time_resolution, #Mort. (sensitive)
    mortalityRateRes = 0.015/time_resolution, #Mort. (resistant)
    movement = 0.1, #Movement in continuous space
    βᵣ = 0.3/time_resolution, #Beta (resistant) NOT TIME DEPENDENT?!
    βₛ = 0.6/time_resolution, #Beta (sensitive)
    age = 1*time_resolution, #Initial age
    init_is = 5, # Number initially infected sensitive
    init_ir = 1, # Number initially infected resistant
    inf_days_is = 0,
    inf_days_ir = 0,
    sponrec_is = 0.05/time_resolution, #chance of spontaneous recovery IS
    sponrec_ir = 0.04/time_resolution,  #chance of spontaneous recovery IR
    timestep = 1.0, #Set model timestep
    treatment = :U,
    days_treated = 0,
    treatment_prob = 0.3/time_resolution,
    treatment_duration = 5*time_resolution,
    since_tx = 0,
    res_carrier = 0.05/time_resolution,
    sens_carrier = 0.01/time_resolution
)
#End header
#Body

#Define the agent space. At present, avoid observing pen boundaries.
agentSpace = ContinuousSpace((10,10), 1; periodic = true) #Relatinship to real space?
#Specify the disease dynamics  as a Dictionary to be passed to the model
pathogenProperties = @dict(
    calfProximityRadius,
    mortalityRateSens,
    mortalityRateRes,
    sponrec_ir,
    sponrec_is,
    timestep, 
    treatment_prob,
    treatment_duration, 
    since_tx,
    res_carrier,
    sens_carrier)# Dictionary of disease properties

# Define the model: Agent type, agent space, properties, and type of random seed
calfModel = ABM(CalfAgent, agentSpace, properties = pathogenProperties, rng = MersenneTwister(seed))

#Define a function to set initial infected status. This gets supplied to the loop describing the initial system state.
function initial_status(n, init_ir, init_is)
    if n ≤ init_is 
        :IS
    elseif n > init_is && n <= (init_is + init_ir)
        :IR
    elseif n > init_is + init_ir
        :S
    end
end

#Define a function parameter to govern the movement of animals in different states

function initial_velocity(status, movement)
    if status == :S
        sincos(2π*rand(calfModel.rng)) .*movement
    elseif status == :IS
        sincos(2π*rand(calfModel.rng)) .*(movement/2)
    elseif status == :IR
        sincos(2π*rand(calfModel.rng)) .*(movement/2.5)
    elseif status == :M
        (0.0,0.0)
    end
end


#Define the initial state of the system. Attributes for each calf in the system.
for n in 1:N
    # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
    pos = Tuple(10*rand(calfModel.rng, 2))
    status = initial_status(n, init_ir, init_is)
    age = age
    βᵣ = βᵣ
    βₛ = βₛ
    treatment = treatment
    treatment_prob = treatment_prob
    days_treated = days_treated
    treatment_duration = treatment_duration
    vel = initial_velocity(status, movement)
    add_agent!(pos, calfModel, vel, age, status, βᵣ, βₛ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx)
end

    return calfModel
end

calfModel = initialiseModel()
