using StatsBase
using PyPlot

#using Pkg
#Pkg.add("StatsBase")
#Pkg.add("PyPlot")

@enum AgentType agentS agentI agentR agentD

struct Agent
    x::Int # location of an agent in x-dimension
    y::Int # location of an agent in y-dimension
    type::AgentType # type of an agent
    tick::Int # moment in time when agent entered type `type`
end

mutable struct Environment
    grid::Matrix{Vector{Int}} # for each cell of a grid a vector of numbers
                              # of agents currently occupying a given cell
    agents::Vector{Agent}     # a vector of all agents
    duration::Int             # metadata: how long agent stays in infected state
    pdeath::Float64           # metadata: probability of death of an agent after
                              # being infected
    stats::Dict{AgentType, Vector{Int}} # a dictionary storing number of agents
                                        # of each type in consecutive ticks
                                        # of the simulation
    tick::Int                 # counter of the current tick of the simulation
end
function init(n::Int, infected::Int,
    duration::Int, pdeath::Float64, xdim::Int, ydim::Int)
grid = [Int[] for _ in 1:xdim, _ in 1:ydim]
agents = [Agent(rand(1:xdim), rand(1:ydim),
          i <= infected ? agentI : agentS, 0) for i in 1:n]
for (i, a) in enumerate(agents)
push!(grid[a.x, a.y], i)
end
stats = Dict(agentS => [n - infected],
       agentI => [infected],
       agentR => [0],
       agentD => [0])
return Environment(grid, agents, duration, pdeath, stats, 0)
end

die(a::Agent, tick::Int) = Agent(a.x, a.y, agentD, tick)

recover(a::Agent, tick::Int) = Agent(a.x, a.y, agentR, tick)

infect(a::Agent, tick::Int) = Agent(a.x, a.y, agentI, tick)

move(a::Agent, dims::Tuple{Int, Int}) =
    if a.type == agentD
        a
    else
        Agent(mod1(a.x + rand(-1:1), dims[1]),
              mod1(a.y + rand(-1:1), dims[2]),
              a.type, a.tick)
    end

    function update_type!(env::Environment)
        tick = env.tick
        for (i, a) in enumerate(env.agents)
            if a.type == agentI
                if tick - a.tick > env.duration
                    env.agents[i] = if rand() < env.pdeath
                        die(a, tick)
                    else
                        recover(a, tick)
                    end
                else
                    a.tick == tick && continue
                    for j in env.grid[a.x, a.y]
                        a2 = env.agents[j]
                        if a2.type == agentS
                            env.agents[j] = infect(a2, tick)
                        end
                    end
                end
            end
        end
    end

    function move_all!(grid::Matrix{Vector{Int}}, agents::Vector{Agent})
        foreach(empty!, grid)
        for (i, agent) in enumerate(agents)
            a = move(agent, size(grid))
            agents[i] = a
            push!(grid[a.x, a.y], i)
        end
    end

    function get_statistics!(env::Environment)
        status = countmap([a.type for a in env.agents])
        for (k, v) in env.stats
            push!(v, get(status, k, 0))
        end
    end

    function run!(env::Environment)
        while env.stats[agentI][end] > 0
            env.tick += 1
            update_type!(env)
            move_all!(env.grid, env.agents)
            get_statistics!(env)
        end
    end
    

    
    e = init(2000, 10, 21, 0.05, 100, 100)
run!(e)
foreach(plot, values(e.stats))
legend(string.(keys(e.stats)))


