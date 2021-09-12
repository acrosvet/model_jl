"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)

if AnimalAgent.calving_season == :Spring
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if animalModel.date == (animalModel.msd + Day(6*7))
                AnimalAgent.pregstat = :P
                AnimalAgent.stage = :DH
                AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(42), 0, 63))))
                println("Heifer joined")
        end
    end
end

if AnimalAgent.calving_season == :Autumn
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if animalModel.date == (animalModel.msd_2 + Day(6*7))
                AnimalAgent.pregstat = :P
                AnimalAgent.stage = :DH
                AnimalAgent.dic = Int(floor(rand(truncated(Rayleigh(42), 0, 63))))
                println("Heifer joined")
        end
    end
end


if AnimalAgent.stage == :H && AnimalAgent.age ≥ 550
    if  AnimalAgent.pregstat == :E
        kill_agent!(AnimalAgent, animalModel)
        println("Culled empty heifer")
    end
end



end
