#Import required Julia packages

using Agents #Agent based models
using Plots #Simple plots
using Random #Pseudorandom number generation
using DrWatson #Utilities for working with dictionaries
using InteractiveDynamics #Plot and animate ABMs
using CairoMakie #Backend for video creation

"""Define a CalfAgent with the following attributes:
* status - infection status Symbol:: S, I, R 
* age - age in days
"""
mutable struct CalfAgent <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2, Float64}
    age::Int
    status::Symbol
    βₛ::Float64
    βᵣ::Float64
end
    
#Define model initialisation functions. 

function initialiseModel(
    N = 60, #Default number of animals
    seed = 42, #Random seed
    calfProximityRadius = 0.5, #Radius for effective contact
    mortalityRateSens = 0.1, #Mort. (sensitive)
    mortalityRateRes = 0.2, #Mort. (resistant)
    movement = 0.2, #Movement in continuous space
    βᵣ = 0.5, #Beta (resistant)
    βₛ = 0.5, #Beta (sensitive)
    age = 1 #Initial age
)
#End header
#Body

#Define the agent space. At present, avoid observing pen boundaries.
agentSpace = ContinuousSpace((10,10), 10; periodic = true)
#Specify the disease dynamics  as a Dictionary to be passed to the model
pathogenProperties = @dict(
    calfProximityRadius,
    mortalityRateSens,
    mortalityRateRes,) # Dictionary of disease properties

# Define the model: Agent type, agent space, properties, and type of random seed
calfModel = ABM(CalfAgent, agentSpace, properties = pathogenProperties, rng = MersenneTwister(seed))

#Define the initial state of the system. Attributes for each calf in the system.
for n in 1:N
    # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
    pos = Tuple(rand(calfModel.rng, 2))
    status =  n ≤ 5 ? :IS : :S # Ternary, define the initial number infected
    age = age
    βᵣ = βᵣ
    βₛ = βₛ
    vel = status == :IS ? sincos(2π*rand(calfModel.rng)) .*(movement/2) : sincos(2π*rand(calfModel.rng)) .*movement
    add_agent!(pos, calfModel, vel, age, status, βᵣ, βₛ)
end

    return calfModel
end

calfModel = initialiseModel()

function model_step!(calfModel)
    #Define the proximity for which infection may occur
    r = calfModel.calfProximityRadius
    for (a1,a2) in interacting_pairs(calfModel, r, :nearest)
        elastic_collision!(a1, a2) #Collison dynamics for each calf
        transmit_sensitive!(a1,a2) #Sensitive transmission function
        transmit_resistant!(a1,a2) #Resistant transmission function
    end
end
    
#Update agent parameters for each time step
function agent_step!(CalfAgent, calfModel)
    move_agent!(CalfAgent, calfModel) #Move the agent in space
    update_agent!(CalfAgent) #Apply the update_agent function
end

#Update agent parameters for each timestep  
function update_agent!(CalfAgent)
    CalfAgent.age =+ 1 # Increment age by 1 day
end
    
"""
Function: transmit_sensitive
Transmission of sensitive bacteria
a1,a2. Position argumetns in continuous space
"""
function transmit_sensitive!(a1,a2)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if rand(calfModel.rng) > infected.βₛ
        return
        # Else we set the status of the healthy animal to IS
    else
        healthy.status = :IS
    end
end

"""
Function: transmit_resistant
Transmission of resistant bacteria
a1,a2. Position argumetns in continuous space
"""
function transmit_resistant!(a1,a2)
    count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
    
infected, healthy = a1.status == :IR ? (a1, a2) : (a2, a1)

if rand(calfModel.rng) > infected.βᵣ
    return
else
    healthy.status = :IR
end
end

# Generate some model plots
calfSim = initialiseModel()
model_colors(a) = a.status == :S ? "#2b2b33" : a.status == :IS ? "#bf2642" : "#338c54"

fig, abmstepper = abm_plot(calfSim; ac = model_colors)
fig # display figure

#Function, extract infected animals and susceptible animals at each timestep
infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
adata = [(:status, infected_sensitive), (:status, susceptible)]

simRun, _ = run!(calfSim, agent_step!, model_step!, 2000; adata)

CSV.write("./run1_export.csv", data1)

using CairoMakie
figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Infected Sensitive")
l1 = lines!(ax, simRun[:, dataname((:status, infected_sensitive))], color = :orange)
l2 = lines!(ax, simRun[:, dataname((:status, susceptible))], color = :green)
figure[1, 2] =
    Legend(figure, [l1], ["Infected Sensitive"])
figure