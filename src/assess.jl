

exposed = findall(x-> x.status == 7, animalModel.animals)
exposed = animalModel.animals[exposed]
for exposed in exposed
    #println(exposed.days_infected)
    println(exposed.id)
    println(exposed.pop_p)
    println(exposed.susceptibility)
end


exposed = findall(x-> x.stage == 1, animalModel.animals)
exposed = animalModel.animals[exposed]
for exposed in exposed
    #println(exposed.days_infected)
    println("====================")
    println(exposed.sex)
    println(exposed.pen)
end


for animal in animalModel.animals
    animal.days_carrier == 0 && continue
    println(animal.days_carrier)
end

statuses = []
for animal in animalModel.animals
    push!(statuses, animal.status)
end

@show countmap(statuses)

for animal in animalModel.animals
    animal.status != 6 && continue
    println(animal.pop_r)
end


statuses = []
carryover = findall(x-> x.stage == 5, animalModel.animals)
carryover = animalModel.animals[carryover]
for carryover in carryover
    #println(carryover.days_infected)
    println(carryover.calving_season)
    push!(statuses, carryover.calving_season)
    #println(carryover.stage)
end

statuses = []
for animal in animalModel.animals
    push!(statuses, animal.status)
end


countmap(carryover.calving_season)