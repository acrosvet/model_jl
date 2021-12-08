include("./src/animal_na.jl")

#@profview 
#@time [animal_step!(animalModel, animalData) for i in 1:365*10]

runs = []

for i in 1:10
  [animal_step!(animalModel, animalData) for j in 1:365]
  push!(runs, animalData)
end

@time export_animalData!(animalData)

write_allData!(allData)

write("data", runs)