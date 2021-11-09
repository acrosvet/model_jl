"""
**cull_milkers!(AnimalAgent, animalModel)

* Cull milkers as a result of repro performance or age

"""

function cull_milkers!(AnimalAgent, animalModel)


cull_empty_dry!(AnimalAgent, animalModel)#cull empty dry cows


#Set a variable for the current number of lactating cows
current_lactating = animalModel.current_lac

# Cull milkers according to the calving system in use
cull_seasonal!(AnimalAgent, animalModel, current_lactating)
cull_split!(AnimalAgent, animalModel, current_lactating)
cull_batch!(AnimalAgent, animalModel, current_lactating)




end