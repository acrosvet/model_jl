using Random
using DataFrames
using BenchmarkTools
using Distributions
using StatsBase

mutable struct Animal
    id::Int
    status::Int
    step::Int
    pop_p::Float16
    pop_r::Float16
    pop_s::Float16
    colonies::DataFrame
    days_exposed::Int
    days_treated::Int
    days_recovered::Int
    days_carrier::Int
    stress::Bool
    rng::MersenneTwister
end

count_status!(col, status) = sum(col .== status)

function count_colonies!(animal)
    animal.pop_r = count_status!(animal.colonies.status, 2)/length(animal.colonies.id)
    animal.pop_p = count_status!(animal.colonies.status, 1)/length(animal.colonies.id)
    animal.pop_s = count_status!(animal.colonies.status, 0)/length(animal.colonies.id)
end

function makeAnimal(;
    id::Int = 1,
    status::Int = 0,
    step::Int = 0,
    days_exposed::Int = 0,
    days_treated::Int = 0,
    days_recovered::Int = 0,
    days_carrier::Int = 0,
    stress::Bool = false,
    maxdays::Int = 3654,
    bactcolonies::Int = 33*33
)

rng = MersenneTwister(id)

pop_p = pop_r = pop_s = 0

colonies = DataFrame(
    id = fill(0,bactcolonies),
    initpos = fill(CartesianIndex(0,0)),
    pos_x = fill(0),
    pos_y = fill(0),
    pos = fill([0,0]),
    status = fill(0, bactcolonies),
    fitness = fill(0.0, bactcolonies),
    processed = fill(false), 
    neighbours = fill([0,0,0,0,0,0,0,0], bactcolonies),
    competing_neighbour = fill(Int(0), bactcolonies), 
    neighbour_fitness = fill(0.0, bactcolonies)
)

pos_n1 = Vector{Int}(undef, bactcolonies)
pos_n2 = Vector{Int}(undef, bactcolonies)
pos_n3 = Vector{Int}(undef, bactcolonies)
pos_n4 = Vector{Int}(undef, bactcolonies)
pos_n5 = Vector{Int}(undef, bactcolonies)
pos_n6 = Vector{Int}(undef, bactcolonies)
pos_n7 = Vector{Int}(undef, bactcolonies)
pos_n8 = Vector{Int}(undef, bactcolonies)

animal = Animal(id, status, step, pop_p, pop_r, pop_s, colonies, days_exposed, days_treated, days_recovered, days_carrier, stress, rng)

colonies.id = [1:1:bactcolonies;]
colonies.initpos = vec(CartesianIndices(zeros(33,33)))
colonies.pos_x = map(i -> i[1], colonies.initpos)
colonies.pos_y = map(i -> i[2], colonies.initpos)

for i in 1:length(colonies.pos_x)
    colonies.pos[i] = [colonies.pos_x[i], colonies.pos_y[i]]
end

for i in 1:length(colonies.pos_x)
    n1 = findfirst(x-> x ==[(colonies.pos_x[i] - 1), (colonies.pos_y[i] + 1)], animal.colonies.pos)
    n1 = n1 === nothing ? 0 : n1
    pos_n1[i] = n1

    n2 = findfirst(x-> x == [colonies.pos_x[i], colonies.pos_y[i] + 1], animal.colonies.pos)
    n2 = n2 === nothing ? 0 : n2
    pos_n2[i] = n2

    n3 = findfirst(x -> x == [colonies.pos_x[i] + 1, colonies.pos_y[i] + 1], animal.colonies.pos)
    n3 = n3 === nothing ? 0 : n3
    pos_n3[i] = n3 

    n4 = findfirst(x-> x == [colonies.pos_x[i] + 1, colonies.pos_y[i]], animal.colonies.pos)
    n4 = n4 === nothing ? 0 : n4
    pos_n4[i] = n4

    n5 = findfirst(x -> x == [colonies.pos_x[i] + 1, colonies.pos_y[i] - 1], animal.colonies.pos)
    n5 = n5 === nothing ? 0 : n5
    pos_n5[i] = n5 

    n6 = findfirst(x-> x == [colonies.pos_x[i], colonies.pos_y[i] - 1], animal.colonies.pos)
    n6 = n6 === nothing ? 0 : n6
    pos_n6[i] = n6

    n7 = findfirst(x-> x == [colonies.pos_x[i] - 1, colonies.pos_y[i] - 1], animal.colonies.pos)
    n7 = n7 === nothing ? 0 : n7
    pos_n7[i] =  n7


    n8 = findfirst(x-> x == [colonies.pos_x[i] - 1, colonies.pos_y[i]], animal.colonies.pos)
    n8 = n8 === nothing ? 0 : n8
    pos_n8[i] = n8
end

neighbours = Vector{Vector{Int}}(undef, bactcolonies)
for i in 1:length(pos_n1)
    neighbours[i] = [pos_n1[i], pos_n2[i], pos_n3[i], pos_n4[i], pos_n5[i], pos_n6[i], pos_n7[i], pos_n8[i]]
    filter!(x-> x != 0, neighbours[i])
end



animal.colonies.neighbours = neighbours



select!(colonies, Not([:initpos, :pos_x, :pos_y]))

if animal.status == 1
    for i in 1:length(colonies.id)
        colonies.id[i] = i
        colonies.status[i] = i % 2 == 0 ? 1 : 0
        colonies.status[i] = i % 200 == 0 ? 2 : colonies.status[i]
        colonies.fitness[i] = rand(animal.rng, 0.95:0.001:0.99)
    end
elseif animal.status == 2
    for i in 1:length(colonies.id)
        colonies.id[i] = i
        colonies.status[i] = i % 2 == 0 ? 2 : 0
        colonies.status[i] = i % 200 == 0 ? 2 : colonies.status[i]
        colonies.fitness[i] = rand(animal.rng, 0.95:0.001:0.99)
    end
else 
    for i in 1:length(colonies.id)
        colonies.id[i] = i
        colonies.status[i] = 0
        colonies.fitness[i] = rand(animal.rng, 0.95:0.001:0.99)
    end
end

count_colonies!(animal)

return(animal)

end

function bact_treatment!(animal)

    animal.days_treated == 0 && return
    path_colonies = findall(animal.colonies.status .≤ 1) 
    for i in path_colonies
        rand(animal.rng) > ℯ^(-animal.days_treated/20) && continue
        animal.colonies.status[i] = 10
        animal.colonies.fitness[i] = 0
    end

end


function bact_repopulate!(animal)

    dead = findall(animal.colonies.status .== 10)

  Threads.@threads  for i in dead
        competing_neighbour = animal.colonies.neighbours[i][rand(1:length(animal.colonies.neighbours[i]))]

        animal.colonies.status[competing_neighbour] ==  10 && continue
        if animal.days_treated != 0 && animal.status ≤ 1
            rand(animal.rng) < 0.5 && return
            animal.colonies.status[competing_neighbour] != 2 && return
            animal.colonies.status[i] = 2
            animal.colonies.processed[i] = true
            animal.colonies.fitness[i] = animal.colonies.fitness[competing_neighbour]
        elseif animal.days_treated == 0 && animal.status ≤ 1
            rand(animal.rng) < 0.5 && return
            animal.colonies.status[i] = animal.colonies.status[competing_neighbour]
            animal.colonies.processed[i] = true
            animal.colonies.fitness[i] = animal.colonies.fitness[competing_neighbour]

        end
    end

end


function bact_carrier!(animal)

    animal.days_carrier != 0 && return

    if animal.status == 6
        for i in animal.colonies.id
            rand(animal.rng) > rand(animal.rng, 0.1:0.01:0.30) && continue
            animal.colonies.processed[i] == true & continue
            animal.colonies.status[i] = 2
            animal.colonies.processed = true
            animal.colonies.fitness = rand(bacterialModel.rng, 0.95:0.001:0.99)
        end
    elseif animal.status == 5
        for i in animal.colonies.id
            rand(animal.rng) > rand(animal.rng, 0.1:0.01:0.30) && continue
            animal.colonies.processed[i] == true & continue
            animal.colonies.status[i] = 1
            animal.colonies.processed = true
            animal.colonies.fitness = rand(bacterialModel.rng, 0.95:0.001:0.99)
        end
    end

end

function bact_fitness!(animal)

    fitness_competition = findall(animal.colonies.fitness .< animal.colonies.neighbour_fitness)

    for competitor in fitness_competition
        competing_neighbour = animal.colonies.neighbours[competitor][rand(1:length(animal.colonies.neighbours[competitor]))]
       animal.colonies.fitness[competitor] > animal.colonies.fitness[competing_neighbour] && continue
        animal.colonies.status[competitor] = animal.colonies.status[competing_neighbour]
        animal.colonies.fitness[competitor] = animal.colonies.fitness[competing_neighbour]
    end


end

function bact_mstep!(animal)

    animal.colonies.processed .= false
    animal.step += 1

  #   transform!(animal.colonies, [:competing_neighbour, :neighbours] => ByRow((a,b) -> a = b[rand(1:length(b))]))
  #   transform!(animal.colonies, [:neighbour_fitness, :competing_neighbour] => ByRow((a,b)-> a =  b == 0 ? 0 : animal.colonies.fitness[b]))



#=        for id in eachindex(animal.colonies.id)
        animal.colonies.competing_neighbour[id] = animal.colonies.neighbours[id][rand(1:length(animal.colonies.neighbours[id]))]
        animal.colonies.neighbour_fitness[id] = animal.colonies.fitness[animal.colonies.competing_neighbour[id]]
       end    =#

end

function bact_exposed!(animal)
    animal.status != 3 || animal.status != 4 && return
    animal.days_exposed == 0 && return
    to_process = findall(animal.colonies.processed .== false)

    if animal.days_exposed == 1
     Threads.@threads   for id  in to_process
            id % 3 != 0 && continue
            animal.colonies.processed[id] == true && continue
            if animal.status == 3
                animal.colonies.status[id] = 1
                animal.colonies.processed[id] = true
            elseif animal.status == 4
                animal.colonies.status[id] = 2
                animal.colonies.processed[id] = true
            end
        end
    elseif animal.days_exposed > 1
      Threads.@threads  for id in to_process
            competing_neighbour = animal.colonies.neighbours[id][rand(1:length(animal.colonies.neighbours[id]))]
            animal.colonies.status[id] != 1 || animal.colonies.status[id] != 2 && continue
            animal.colonies.processed[id] == true && continue
            animal.colonies.status[competing_neighbour] = animal.colonies.status[id]
            animal.colonies.processed[competing_neighbour] = true
        end
    end

end

function bact_recovery!(animal)

    animal.days_recovered == 0 && return
    animal.status != 7 || animal.status != 8 && return

   # recoveries = 
 Threads.@threads   for recovery in findall(animal.colonies.status .== 1 .|| animal.colonies.status .== 2)
        rand(animal.rng) > ℯ^(-animal.days_recovered/20) && continue
        animal.colonies.status[recovery] = 0
        animal.colonies.processed[recovery] = true
    end


end


function animal_step!(animal)
    bact_mstep!(animal)
    bact_treatment!(animal)
    bact_recovery!(animal)
    bact_repopulate!(animal)
    bact_carrier!(animal)
    bact_fitness!(animal)
    bact_exposed!(animal)
    count_colonies!(animal)
end
