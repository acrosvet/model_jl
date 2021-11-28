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

#Calve all animals at day 273 to 293

    if AnimalAgent.dic == 283 + rand(animalModel.rng, -10:1:10)
        AnimalAgent.pregstat = :E
        AnimalAgent.dic = 0
        AnimalAgent.stage = :L
        AnimalAgent.dim = 1
        AnimalAgent.lactation += 1
        higher_dimension!(AnimalAgent, animalModel, stage = :L, level = 5, density = 6)
        birth!(AnimalAgent, animalModel)
               
    end
end