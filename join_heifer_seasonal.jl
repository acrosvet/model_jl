function join_heifer_seasonal!(AnimalAgent, animalModel)

    #Seasonal herds ------------------------------------------------------------

if animalModel.system == :Seasonal

    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if animalModel.date == (animalModel.msd + Day(6*7))
                AnimalAgent.pregstat = :P
                AnimalAgent.stage = :DH
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(50), 0, 63))))
                higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
               # println("Heifer joined")
        end
    end

end


end