# # SIR model for the spread of COVID-19
# ```@raw html
# <video width="auto" controls autoplay loop>
# <source src="../covid_evolution.mp4" type="video/mp4">
# </video>
# ```
#
# This example illustrates how to use `GraphSpace` and how to model agents on an graph
# (network) where the transition probabilities between each node (position) is not constant.
# ## SIR model

# A SIR model tracks the ratio of Susceptible, Infected, and Recovered individuals within a population.
# Here we add one more category of individuals: those who are infected, but do not know it.
# Transmission rate for infected and diagnosed individuals is lower than infected and undetected.
# We also allow a fraction of recovered individuals to catch the disease again, meaning
# that recovering the disease does not bring full immunity.

# ## Model parameters
# Here are the model parameters, some of which have default values.
# * `Ns`: a vector of population sizes per city. The amount of cities is just `C=length(Ns)`.
# * `β_und`: a vector for transmission probabilities β of the infected but undetected per city.
#   Transmission probability is how many susceptible are infected per day by an infected individual.
#   If social distancing is practiced, this number increases.
# * `β_det`: an array for transmission probabilities β of the infected and detected per city.
#   If hospitals are full, this number increases.
# * `infection_period = 30`: how many days before a person dies or recovers.
# * `detection_time = 14`: how many days before an infected person is detected.
# * `death_rate = 0.02`: the probability that the individual will die after the `infection_period`.
# * `reinfection_probability = 0.05`: The probability that a recovered person can get infected again.
# * `migration_rates`: A matrix of migration probability per individual per day from one city to another.
# * `Is = [zeros(C-1)..., 1]`: An array for initial number of infected but undetected people per city.
#   This starts as only one infected individual in the last city.

# Notice that `Ns, β, Is` all need to have the same length, as they are numbers for each
# city. We've tried to add values to the infection parameters similar to the ones you would hear
# on the news about COVID-19.

# The good thing with Agent based models is that you could easily extend the model we
# implement here to also include age as an additional property of each agent.
# This makes ABMs flexible and suitable for research of virus spreading.

# ## Making the model in Agents.jl
# We start by defining the `PoorSoul` agent type and the ABM
cd(@__DIR__) #src
using Agents, Random, DataFrames, LightGraphs
using Distributions: Poisson, DiscreteNonParametric
using DrWatson: @dict
using CairoMakie

mutable struct PoorSoul <: AbstractAgent
    id::Int
    pos::Int
    days_infected::Int  # number of days since is infected
    status::Symbol  # 1: S, 2: I, 3:R
end

function model_initiation(;
    Ns, # population size per city
    migration_rates, # Migration rates 
    β_und, # beta for undetected
    β_det, # beta for detected
    infection_period = 30, # Infection periodic
    reinfection_probability = 0.05, # Likelihood of reinfection 
    detection_time = 14, # Time from infection to detection
    death_rate = 0.02, # Mortality rate
    Is = [zeros(Int, length(Ns) - 1)..., 1], # Array, initial number of people infected per city
    seed = 0, # Seed for random
)

    rng = MersenneTwister(seed) # Set a range of random numbers based on the random seed defined
    @assert length(Ns) == # With assertion error. Define length of population
    length(Is) == #Infection array
    length(β_und) == # beta
    length(β_det) == # beta det
    size(migration_rates, 1) "length of Ns, Is, and B, and number of rows/columns in migration_rates should be the same "
    @assert size(migration_rates, 1) == size(migration_rates, 2) "migration_rates rates should be a square matrix"

    C = length(Ns)
    ## normalize migration_rates
    migration_rates_sum = sum(migration_rates, dims = 2)
    for c in 1:C
        migration_rates[c, :] ./= migration_rates_sum[c]
    end
# Properties, a dictionary for initiated model parameters
    properties = @dict(
        Ns,
        Is,
        β_und,
        β_det,
        β_det,
        migration_rates,
        infection_period,
        infection_period,
        reinfection_probability,
        detection_time,
        C,
        death_rate
    )
    # Initiate the graph space
    space = GraphSpace(complete_digraph(C))
    # Set up the model
    model = ABM(PoorSoul, space; properties, rng)

    ## Add initial individuals
    # for the cities and their populations 
    for city in 1:C, n in 1:Ns[city]
        # Add aggents based on the model that are susceptible
        ind = add_agent!(city, model, 0, :S) # Susceptible
    end
    ## add infected individuals
    for city in 1:C
        inds = ids_in_position(city, model)
        for n in 1:Is[city]
            agent = model[inds[n]]
            agent.status = :I # Infected
            agent.days_infected = 1
        end
    end
    return model
end
nothing # hide

# *The model only takes the argument for the number of cities*

# We will make a function that starts a model with `C` number of cities,
# and creates the other parameters automatically by attributing some random
# values to them. You could directly use the above constructor and specify all
# `Ns, β`, etc. for a given set of cities.

# All cities are connected with each other, while it is more probable to travel from a city
# with small population into a city with large population.

using LinearAlgebra: diagind
# Specify all the parameters for the model
function create_params(;
    C,
    max_travel_rate,
    infection_period = 30,
    reinfection_probability = 0.05,
    detection_time = 14,
    death_rate = 0.02,
    Is = [zeros(Int, C - 1)..., 1],
    seed = 19,
)

    Random.seed!(seed)
    Ns = rand(50:5000, C)
    β_und = rand(0.3:0.02:0.6, C)
    β_det = β_und ./ 10

    Random.seed!(seed)
    migration_rates = zeros(C, C)
    for c in 1:C
        for c2 in 1:C
            migration_rates[c, c2] = (Ns[c] + Ns[c2]) / Ns[c]
        end
    end
    maxM = maximum(migration_rates)
    migration_rates = (migration_rates .* max_travel_rate) ./ maxM
    migration_rates[diagind(migration_rates)] .= 1.0

    params = @dict(
        Ns,
        β_und,
        β_det,
        migration_rates,
        infection_period,
        reinfection_probability,
        detection_time,
        death_rate,
        Is
    )

    return params
end

params = create_params(C = 8, max_travel_rate = 0.01)
model = model_initiation(; params...)

# ## SIR Stepping functions

# Now we define the functions for modelling the virus spread in time

function agent_step!(agent, model)
    migrate!(agent, model)
    transmit!(agent, model)
    update!(agent, model)
    recover_or_die!(agent, model)
end

function migrate!(agent, model)
    pid = agent.pos
    d = DiscreteNonParametric(1:(model.C), model.migration_rates[pid, :])
    m = rand(model.rng, d)
    if m ≠ pid
        move_agent!(agent, m, model)
    end
end

function transmit!(agent, model)
    agent.status == :S && return
    rate = if agent.days_infected < model.detection_time
        model.β_und[agent.pos]
    else
        model.β_det[agent.pos]
    end

    d = Poisson(rate)
    n = rand(model.rng, d)
    n == 0 && return

    for contactID in ids_in_position(agent, model)
        contact = model[contactID]
        if contact.status == :S ||
           (contact.status == :R && rand(model.rng) ≤ model.reinfection_probability)
            contact.status = :I
            n -= 1
            n == 0 && return
        end
    end
end

update!(agent, model) = agent.status == :I && (agent.days_infected += 1)

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

# ## Example animation

# First, we'll define a few variables that look over aspects of the model
total_infected(m) = count(a.status == :I for a in allagents(m))
infected_fraction(x) = cgrad(:inferno)[count(model[id].status == :I for id in x) / length(x)]
s = Observable(0) # Current step
total = Observable(total_infected(model)) # Number of infected across all cities
color = Observable(infected_fraction.(model.space.s)) # Percentage of infected people per city
title = lift((c, t) -> "Step = "*string(c)*", Infected = "*string(t), s, total)

# Then, initialise the model and view the contagion:

model = model_initiation(; params...)
figure = Figure(resolution = (600, 400))
ax = figure[1, 1] = Axis(figure; title, xlabel = "City", ylabel = "Population")
barplot!(ax, model.Ns, strokecolor = :black, strokewidth = 1; color)
record(figure, "covid_evolution.mp4"; framerate = 5) do io
    for j in 1:40
        recordframe!(io)
        Agents.step!(model, agent_step!, 1)
        color[] = infected_fraction.(model.space.s)
        s[] += 1
        total[] = total_infected(model)
    end
    recordframe!(io)
end
nothing # hide
# ```@raw html
# <video width="auto" controls autoplay loop>
# <source src="../covid_evolution.mp4" type="video/mp4">
# </video>
# ```

# One can really see "explosive growth" in this animation. Things look quite calm for
# a while and then suddenly supermarkets have no toilet paper anymore!

# ## Exponential growth

# We now run the model and collect data. We define two useful functions for
# data collection:
infected(x) = count(i == :I for i in x)
recovered(x) = count(i == :R for i in x)
nothing # hide

# and then collect data
model = model_initiation(; params...)

to_collect = [(:status, f) for f in (infected, recovered, length)]
data, _ = run!(model, agent_step!, 100; adata = to_collect)
data[1:10, :]

# We now plot how quantities evolved in time to show
# the exponential growth of the virus

N = sum(model.Ns) # Total initial population
x = data.step
figure = Figure(resolution = (600, 400))
ax = figure[1, 1] = Axis(figure, xlabel = "steps", ylabel = "log10(count)")
li = lines!(ax, x, log10.(data[:, aggname(:status, infected)]), color = :blue)
lr = lines!(ax, x, log10.(data[:, aggname(:status, recovered)]), color = :red)
dead = log10.(N .- data[:, aggname(:status, length)])
ld = lines!(ax, x, dead, color = :green)
figure[1, 2] = Legend(figure, [li, lr, ld], ["infected", "recovered", "dead"], textsize = 12)
figure

# The exponential growth is clearly visible since the logarithm of the number of infected increases
# linearly, until everyone is infected.