"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)


    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if animalModel.date == (animalModel.msd + Day(6*7))
            if rand(animalModel.rng) < 0.28
                AnimalAgent.pregstat = :P
                AnimalAgent.stage = :DH
                AnimalAgent.dic = rand(truncated(Poisson(42), 0, 63))
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
