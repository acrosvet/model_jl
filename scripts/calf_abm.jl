using Base: Int64, Float64, Bool
# Define the modules that are gooing to be used

using DrWatson: @dict
using Agents, Random, DataFrames, LightGraphs
using Distributions: Poisson, DiscreteNonParametric
using CairoMakie
using InteractiveDynamics

cd(@__DIR__) #src

mutable struct Calves <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    mass::Float64
    days_infected::Int  # number of days since is infected
    status::Symbol  # :S, :I or :R
    β_s::Float64
    β_r::Float64
    age::Int64 # Integer for age in days, will change every day
    fpt::Bool # Boolean value for passive transfer

end


# Define the model --------------------------------------

const steps_per_day = 24 # Number of time steps per day


function init_calf_sir(; 
    infection_period = 3 * steps_per_day, #Infectious for 3 days
    detection_time = 0.5 * steps_per_day, # Detected after 0.5 days 
    identification_probability = 0.2,
    treatment_probability = 0.8, # 80% chance of being treated
    isolated = 0.3, # in percentage # 3% isolated 
    interaction_radius = 0.05, # UNITS UNCLEAR
    dt = 1.0, #Timestep
    speed = 0.02, #Speed of movement, relative to what?
    death_rate = 0.05, # 5% mortality
    N = 30, #30 calves in a pen
    initial_infected_sens = 3, # Initial sensitive
    initial_infected_res = 1, # Initial infected resistant
    seed = 42, # Random seed
    age = 1.0,
    βmin_s = 0.8, # Minimum transmission
    βmax_s = 0.9, # Maximum transmission
    βmin_r = 0.2, # Minimum transmission
    βmax_r = 0.4, # Maximum transmission
    fpt = false

)

    properties = @dict(
        age,
        identification_probability,
        infection_period,
        initial_infected_sens,
        initial_infected_res,
        treatment_probability,
        detection_time,
        death_rate,
        interaction_radius,
        dt,
        fpt,
    )



    space = ContinuousSpace((1,1), 0.02)# How to grid size and spacing affect this?

    model = ABM(Calves, space, properties = properties, rng = MersenneTwister(seed))

    ## Add initial individuals
    for ind in 1:N
        pos = Tuple(rand(model.rng, 2)) #
        status = ind ≤ N - initial_infected_sens - initial_infected_res ? :S : :IS #ifelse s or is 
        isisolated = ind ≤ identification_probability*isolated * N # Prob of a calf being infected and isolated
        mass = isisolated ? Inf : 1.0 # Make sure the isolated calves don't move
        vel = isisolated ? (0.0, 0.0) : sincos(2π * rand(model.rng)) .* speed # Define a function for how they move
        age = 1 # Animal age
        fpt = 0.3 < rand(model.rng) ? :true : :false #Boolean, failure of passive transfer
        ## very high transmission probability
        β_s = (βmax_s - βmin_s) * rand(model.rng) + βmin_s # Beta for sensitive
        β_r = (βmax_r - βmin_r) * rand(model.rng) + βmin_r # Beta for resistant
        add_agent!(pos, model, vel, mass, 0, status, β_s, β_r, age, fpt)
    end

    return model
end
nothing # hide

sir_model = init_calf_sir()


sir_colors(a) = a.status == :S ? "#2b2b33" : a.status == :IS ? "#bf2642" : "#338c54"

fig, abmstepper = abm_plot(sir_model; ac = sir_colors)
fig # display figure

function transmit!(a1, a2, rp)
    ## for transmission, only 1 can have the disease (otherwise nothing happens)
    count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
    infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

    rand(model.rng) > infected.β_s && return

    if healthy.status == :R
        rand(model.rng) > rp && return
    end
    healthy.status = :IS
end

function sir_model_step!(model)
    r = model.interaction_radius
    for (a1, a2) in interacting_pairs(model, r, :nearest)
        transmit!(a1, a2, model.identification_probability)
        elastic_collision!(a1, a2, :mass)
    end
end
nothing # hide

# Notice that it is not necessary that the transmission interaction radius is the same
# as the billiard-ball dynamics. We only have them the same here for convenience,
# but in a real model they will probably differ.

# We also modify the `agent_step!` function, so that we keep track of how long the
# agent has been infected, and whether they have to die or not.

function sir_agent_step!(agent, model)
    move_agent!(agent, model, model.dt)
    update!(agent)
    recover_or_die!(agent, model)
end

update!(agent) = agent.status == :IS && (agent.days_infected += 1)

function recover_or_die!(agent, model)
    if agent.days_infected ≥ model.infection_period
        if rand(model.rng) ≤ model.death_rate
            kill_agent!(agent, model)
        else
            agent.status = :R
            agent.days_infected = 0
        end
    end
end
nothing # hide
sir_model = init_calf_sir()

abm_video(
    "calf_1.mp4",
    sir_model,
    sir_agent_step!,
    sir_model_step!;
    title = "SIR model",
    frames = 100,
    ac = sir_colors,
    as = 10,
    spf = 1,
    framerate = 20,
)

infected(x) = count(i == :IS for i in x)
recovered(x) = count(i == :R for i in x)
adata = [(:status, infected), (:status, recovered)]


sir_model1 = init_calf_sir()

model = sir_model

data1, _ = run!(sir_model, sir_agent_step!, sir_model_step!, 2000; adata)

# Now, we can plot the number of infected versus time
using CairoMakie
figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Infected")
l1 = lines!(ax, data1[:, dataname((:status, infected))], color = :orange)
l2 = lines!(ax, data2[:, dataname((:status, healthy))], color = :blue)
l3 = lines!(ax, data3[:, dataname((:status, infected))], color = :green)
figure[1, 2] =
    Legend(figure, [l1, l2, l3], ["r=$r1, beta=$β1", "r=$r2, beta=$β1", "r=$r1, beta=$β2"])
figure