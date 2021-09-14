"""
**calving!(AnimalAgent, animalModel):**\n

Calve cows based on their number of days in calf (AnimalAgent.dic) within ± 14 days of the gestation length of 283 days.\n

After calving:
* Change the days in calf to 0
* Change the pregnancy status to E
* Change the stage to lactating
* Set the days in milk to 0
* Increment the lactation number

"""
function calving!(AnimalAgent, animalModel)

    num_calves = [a.stage == :C for a in allagents(animalModel)]
    num_calves = sum(num_calves)
    calf_range = Int(floor(3*√num_calves))

    if AnimalAgent.dic == 283
        if AnimalAgent.stage == :DH
           println("Heifer calved")
        end
        AnimalAgent.pregstat = :E
        AnimalAgent.dic = 0
        AnimalAgent.stage = :L
        AnimalAgent.dim = 1
        AnimalAgent.lactation += 1
        pos = (rand(animalModel.rng, 1:calf_range, 2)..., 5)
        while !isempty(pos, animalModel)
            pos = (rand(animalModel.rng, 1:calf_range, 2)..., 5)
        end
        move_agent!(AnimalAgent, pos, animalModel)
        birth!(AnimalAgent, animalModel)
               
    end
end
