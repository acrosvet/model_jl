"""
**joining!(AnimalAgent)**\n

* Start joining pregnant cows after msd and once cow has calved
* Ensures the current date is greater than or equal to mating start date
* Animal DIM must be greater than 42 to allow for uterine involution

"""
function joining!(AnimalAgent, animalModel)

join_seasonal!(AnimalAgent, animalModel)
join_split!(AnimalAgent, animalModel)
join_batch(AnimalAgent, animalModel)

end

