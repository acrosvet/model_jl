"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)

    
#Seasonal herds ------------------------------------------------------------

if animalModel.system == :Seasonal

        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    println("Heifer joined")
            end
        end

end


#Continuous herds ------------------------------------------------------------

if animalModel.system == :Continuous

    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if AnimalAgent.age == 447 && rand(animalModel.rng) > 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.stage = :DH
                AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                println("Heifer joined")
        end
    end

end


# Split herds ---------------------------------------------------------------
if animalModel.system == :Split
    if AnimalAgent.calving_season == :Spring
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    println("Heifer joined")
            end
        end
    end

    if AnimalAgent.calving_season == :Autumn
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd_2 + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    println("Heifer joined")
            end
        end
    end
end

if AnimalAgent.stage == :H && AnimalAgent.age ≥ 550
    if  AnimalAgent.pregstat == :E
        culling_reason = "Empty heifer"
        export_culling!(AnimalAgent, animalModel, culling_reason)
        kill_agent!(AnimalAgent, animalModel)
    end
end

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
                    println("Heifer joined")
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
                    println("Heifer joined")
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
                    println("Heifer joined")
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
                    println("Heifer joined")
            end
        end
    end
    

end

end
