include("packages.jl")
## Define the agents
mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Float64}
    vel::NTuple{2, Float64}
    bactostatus::Symbol
    treatment::Symbol
    strain::Int64
    age::Int
    max_life::Int
    drug_conc::Int
end

## Define the model

const time_units = 24

function initialisePopulation(

    nbact = 100,
    seed = 42,
    contactRadius = 0,
    senesence = 0.05/time_units,
    proliferation = 0.05/time_units,
    movement = 0.05,
    bactostatus = :S,
    treatment = :Y,
    strain = 1,
    nstrains = 4,
    timestep = 1.0, #Set model timestep
    r_strain = rand(1:nstrains),
    age = 1,
    max_life = 2,
    drug_conc = 0,

)

agentSpace = ContinuousSpace((1,1), 1; periodic = true)

properties = @dict(
    nbact,
    seed,
    contactRadius,
    senesence,
    proliferation,
    bactostatus,
    treatment,
    nstrains,
    strain,
    movement,
    timestep,
    r_strain,
    age,
    max_life,
    drug_conc,
)

bacterialModel = ABM(BacterialAgent, agentSpace, properties = properties, rng = MersenneTwister(seed))





# Define the initial initial velocity

function initial_velocity(bactostatus, movement)
    if bactostatus == :S
        sincos(2π*rand(bacterialModel.rng)) .*movement
    else
        sincos(2π*rand(bacterialModel.rng)) .*(movement)
    end
end
            

# Set up the initial parameters
for n in 1:nbact
    treatment = treatment
    r_strain = r_strain
    strain = rand(1:nstrains)
    bactostatus = (strain == r_strain) ? :R : :S
    pos = Tuple(rand(bacterialModel.rng, 2))
    vel = initial_velocity(bactostatus, movement)
    age = age
    max_life = max_life
    add_agent!(pos, bacterialModel, vel, bactostatus, treatment, strain, age, max_life, drug_conc)
end

    return bacterialModel

end

bacterialModel = initialisePopulation()


# Replace function 
function replace_agent!(BacterialAgent, bacterialModel)

    if BacterialAgent.age >= BacterialAgent.max_life
        kill_agent!(BacterialAgent, bacterialModel)
    end

end




# Define the model stepping function

function model_step!(bacterialModel)
    #Define the proximity for which infection may occur
    r = bacterialModel.contactRadius
    for (a1,a2) in interacting_pairs(bacterialModel, r, :nearest)
        elastic_collision!(a1, a2) #Collison dynamics for each bacteria
    end
end

# Define the agent updating function

#Update agent parameters for each timestep  
function update_agent!(BacterialAgent)

    # Update the age 
    BacterialAgent.age =+ 1

end
    
# Define the agent stepping function
#Update agent parameters for each time step

function agent_step!(BacterialAgent, bacterialModel)
    #periodic_position!(CalfAgent, calfModel) #Constrain position twice daily.
    move_agent!(BacterialAgent, bacterialModel, bacterialModel.timestep) #Move the agent in space
    update_agent!(BacterialAgent) #Apply the update_agent function
    replace_agent!(BacterialAgent, bacterialModel)

end

bactoSim = initialisePopulation()

#Function, extract infected animals and susceptible animals at each timestep
resistant(x) = count(i == :R for i in x)
sensitive(x) = count(i == :S for i in x)
strain_1(x) = count(i == 1 for i in x)
strain_2(x) = count(i == 2 for i in x)
strain_3(x) = count(i == 3 for i in x)
strain_4(x) = count(i == 4 for i in x)
adata = [
 (:bactostatus, resistant),
 (:bactostatus, sensitive),
 (:strain, strain_1),
 (:strain, strain_2),
 (:strain, strain_3),
 (:strain, strain_4)
]

bactoSimRun, _ = run!(bactoSim, agent_step!, model_step!, 100; adata)

CSV.write("./bacto_export.csv", bactoSimRun)


