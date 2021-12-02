
include("./src/animal_na.jl")


@time animal_step!(animalModel, animalData)
#@profview animal_step!(animalModel, animalData)



#@profview 
@time [animal_step!(animalModel, animalData) for i in 1:1825]

@time export_animalData!(animalData)

write_allData!(allData)