for i in 1:length(animalModel.animals)
    animal = animalModel.animals[i]
    for neighbour in 1:length(animal.neighbours)
        competing_neighbour = filter(x -> animal.pos == neighbour, animalModel.animals)
        println(competing_neighbour)
        isempty(competing_neighbour) == true && continue
        competing_neighbour.status != 0  && continue
        animal.status % 2 == 0 ? competing_neighbour.status = 4 : competing_neighbour.status = 3
        animal.days_exposed = 1
    end
end

