"""
**dryoff!(AnimalAgent)
"""
function dryoff!(AnimalAgent, animalModel)

    dryoff_seasonal!(AnimalAgent, animalModel)
    dryoff_split!(AnimalAgent, animalModel)
    dryoff_batch!(AnimalAgent, animalModel)

end