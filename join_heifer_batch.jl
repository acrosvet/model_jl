function join_heifer_batch!(AnimalAgent, animalModel)


# Batch herds ---------------------------------------------

if animalModel.system == :Batch

    # Batch 1 -------------------------------------------------
    if AnimalAgent.calving_season == :B1
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    #println("Heifer joined")
            end
        end
    end

    # Batch 2 --------------------------------------------------
    if AnimalAgent.calving_season == :B2
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd_2 - Year(1) + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    #println("Heifer joined")
            end
        end
    end

    # Batch 3 ---------------------------------------------------

    if AnimalAgent.calving_season == :B3
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd_3 + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    #println("Heifer joined")
            end
        end
    end
    
    # Batch 4 ---------------------------------------------------

    if AnimalAgent.calving_season == :B4
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd_4 + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    #println("Heifer joined")
            end
        end
    end
    

end

end