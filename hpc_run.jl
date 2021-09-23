# Add packages
#= Pkg.add("Agents")
Pkg.add("Random")
Pkg.add("DrWatson")
Pkg.add("CSV")
Pkg.add("InteractiveDynamics")
Pkg.add("CairoMakie")
Pkg.add("SparseArrays")
Pkg.add("LightGraphs")
Pkg.add("Distributions")
Pkg.add("DataFrames")
Pkg.add("Dates") =#

# Load packages
using Agents
using Random
using DrWatson
using CSV
using InteractiveDynamics #Plot and animate ABMs
using CairoMakie #Backend for video creationusing SimpleWeightedGraphs: SimpleWeightedDiGraph # will make social network
using SparseArrays: findnz                        # for social network connections
using LightGraphs
using Distributions
using DataFrames
using Dates #Package for working with dates

include("testing.jl")


@time tmp = initialiseSeasonal(50)


header = DataFrame(
    Day = 0,
    ModelStep = 0,
    FarmID = 0,
    AnimalID = 0,
    AnimalStatus = 0,
    AnimalStage = 0,
    DaysInfected = 0,
    DaysExposed = 0,
    DaysCarrier = 0,
    AnimalTreatment = 0,
    DaysTreated = 0,
    DaysSinceTreatment = 0,
    DaysDry = 0,
    TradeStatus = 0,
    AnimalBactoPop_r = 0,
    AnimalBactoPop_is = 0,
    AnimalAge = 0,
    AgentType = 0,
    DIM = 0,
    PregStat = 0,
    dic = 0,
    psc = 0,
    msd = 0,
    CurrentLac = 0,
)

output = open("./export/seasonal_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
    close(output)

pos_header = DataFrame(
    Day = 0, 
    step = 0,
    stage = 0,
    x = 0,
    y = 0,
    z = 0
)

pos_output = open("./export/seasonal_positions.csv","w")
    CSV.write(pos_output, pos_header, delim = ",", append = true, header = true)
close(pos_output)

contact_header = DataFrame(
    agent = 0,
    Day = 0,
    agent_id = 0,
    agent_stage = 0,
    contact_id = 0,
    contact_stage = 0,
    number_contacted = 0,
    agent_status = 0,
    contact_status = 0,
    outcome = 0
)

contact_output = open("./export/seasonal_contacts.csv", "w")
    CSV.write(contact_output, contact_header, delim = ",", append = true, header = true)
close(contact_output)

culling_header = DataFrame(
    step = 0,
    Day = 0,
    culled_id = 0,
    age = 0,
    pregstat = 0,
    dim = 0,
    dic = 0,
    reason = 0
)

culling_output = open("./export/seasonal_culling.csv", "w")
    CSV.write(culling_output, culling_header, delim = ",", append = true, header = true)
close(culling_output)

@time Threads.@spawn run!(tmp, agent_step!, model_step!, 365)

step!(tmp, agent_step!, model_step!) 