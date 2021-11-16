"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)

    
join_heifer_seasonal!(AnimalAgent, animalModel)
join_heifer_batch!(AnimalAgent, animalModel)
join_heifer_split!(AnimalAgent, animalModel)



end
