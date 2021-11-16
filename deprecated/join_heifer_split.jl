function join_heifer_split!(AnimalAgent, animalModel)

    # Split herds ---------------------------------------------------------------
if animalModel.system == :Split
    if AnimalAgent.calving_season == :Spring
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

    if AnimalAgent.calving_season == :Autumn
        if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
            if animalModel.date == (animalModel.msd_2 + Day(6*7))
                    AnimalAgent.pregstat = :P
                    AnimalAgent.stage = :DH
                    AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(50), 0, 63))))
                    higher_dimension!(AnimalAgent, animalModel, stage = :DH, level = 4, density = 7)
                    #println("Heifer joined")
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
end