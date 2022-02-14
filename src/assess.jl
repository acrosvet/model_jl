

exposed = findall(x-> x.status == 5, animalModel.animals)
exposed = animalModel.animals[exposed]
for exposed in exposed
    #println(exposed.days_infected)
    println(exposed.pop_p)
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