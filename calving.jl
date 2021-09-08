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
function calving!(AnimalAgent)

    if AnimalAgent.dic ≥ 283 
        AnimalAgent.pregstat = :E
        AnimalAgent.dic = 0
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
        AnimalAgent.lactation += 1
    end
end