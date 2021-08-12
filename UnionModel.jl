# CalfAgent -----------------------------------------------
    # Define the agent --------------------
    mutable struct CalfAgent <: AbstractAgent
        id::Int
        pos::NTuple{2,Float64}
        vel::NTuple{2, Float64}
        age::Int
        status::Symbol
        βₛ::Float64
        βᵣ::Float64
        inf_days_is::Int
        inf_days_ir::Int
        treatment::Symbol
        days_treated::Int
        since_tx::Int
    end

    # Set the time resolution ------------


    const time_resolution = 24

# BacterialAgent ------------------------------------

    ## Define the agents
    mutable struct BacterialAgent <: AbstractAgent
        id::Int64
        pos::NTuple{2,Float64}
        vel::NTuple{2, Float64}
        bactostatus::Symbol
        strain::Int64
        days_treated::Int
        age::Int
    end

    ## Define the model

    const time_resolution = 24

# Initialise model with mixed agent types ---------------------------------

function initialisePopulation(

    nbact = 10000,
    seed = 42,
    bactostatus = :S,
    strain = 1,
    nstrains = 4,
    timestep = 1.0, #Set model timestep
    r_strain = rand(1:nstrains),
    fitness = 0, 
    days_treated = 0,
    treatment_start = rand(0:100)*time_resolution,
    N = 60, #Default number of animals
    calfProximityRadius = 0.5, #Radius for effective contact
    mortalityRateSens = 0.01/time_resolution, #Mort. (sensitive)
    mortalityRateRes = 0.015/time_resolution, #Mort. (resistant)
    movement = 0.1, #Movement in continuous space
    βᵣ = 0.3/time_resolution, #Beta (resistant) NOT TIME DEPENDENT?!
    βₛ = 0.6/time_resolution, #Beta (sensitive)
    age = 0, #Initial age
    init_is = 5, # Number initially infected sensitive
    init_ir = 1, # Number initially infected resistant
    inf_days_is = 0,
    inf_days_ir = 0,
    sponrec_is = 0.05/time_resolution, #chance of spontaneous recovery IS
    sponrec_ir = 0.04/time_resolution,  #chance of spontaneous recovery IR
    treatment = :U,
    treatment_prob = 0.3/time_resolution,
    treatment_duration = 5*time_resolution,
    since_tx = 0,
    res_carrier = 0.05/time_resolution,
    sens_carrier = 0.01/time_resolution

)
agentSpace = ContinuousSpace((10, 10); periodic = true)

properties = @dict(
    nbact,
    seed,
    bactostatus,
    nstrains,
    strain,
    timestep,
    r_strain,
    days_treated,
    treatment_start,
    fitness,
    age,
    calfProximityRadius,
    mortalityRateSens,
    mortalityRateRes,
    sponrec_ir,
    sponrec_is,
    treatment_prob,
    treatment_duration, 
    since_tx,
    res_carrier,
    sens_carrier
)

unionModel = ABM(Union{CalfAgent,BacterialAgent}, agentSpace, properties = properties, rng = MersenneTwister(seed))

# Utility functions --------------------------------------

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

        # strain fitness

    function bact_fitness()
        rand(2:7)/10
    end


# Create CalfAgents --------------------
id = 0
#Define the initial state of the system. Attributes for each calf in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        id += 1
        pos = Tuple(10*rand(unionModel.rng, 2))
        status = initial_status(n, init_ir, init_is)
        age = age
        βᵣ = βᵣ
        βₛ = βₛ
        treatment = treatment
        treatment_prob = treatment_prob
        days_treated = days_treated
        treatment_duration = treatment_duration
        vel = initial_velocity(status, movement)
        calf = CalfAgent(id, pos, vel, age, status, βₛ, βᵣ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx)
        add_agent!(calf, unionModel)
    end

# Create the BacterialAgents --------------------------

 # Set up the initial parameters
 for n in 1:nbact
    id += 1
    vel = (0.0,0.0)
    r_strain = r_strain
    strain = rand(1:nstrains)
    bactostatus = (strain == r_strain) ? :R : :S
    pos = Tuple(10*rand(unionModel.rng, 2))
    days_treated = days_treated
    treatment_start = treatment_start
    fitness = [bact_fitness() for i in 1:strain]
    bacteria = BacterialAgent(id, pos, vel, bactostatus, strain, days_treated, age)
    add_agent!(bacteria, unionModel)
end

return unionModel

end

unionModel = initialisePopulation()