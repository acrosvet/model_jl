"""
**heifer_joining!(AnimalAgent, animalModel)**

* Join heifers

"""

function heifer_joining!(AnimalAgent, animalModel)
    
    if AnimalAgent.stage == :H && AnimalAgent.pregstat == :E
        if (animalModel.date ≥ (animalModel.msd - Day(21))) && (animalModel.date ≤ (animalModel.msd + Day(9*7)))
            #if (AnimalAgent.age - 13*30 % 21 == 0)
            if (Dates.value(animalModel.date - (animalModel.msd - Day(21)))) in rand(animalModel.rng, truncated(Poisson(10), 21, 12*7), 100)
                #if rand(animalModel.rng) > 0.5
                    AnimalAgent.pregstat = :P
                    AnimalAgent.dic = 1
                    AnimalAgent.stage = :DH
                    age = AnimalAgent.age
                    date = animalModel.date
                    msd = animalModel.msd
                    evala = (Dates.value(animalModel.date - (animalModel.msd - Day(21))))
                    println("Expression evaluates to $evala")
                    println("Date is $date and msd is $msd")
                    println("Heifer joined at age $age")
                #end
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
