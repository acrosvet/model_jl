"""
**bobby_cull!(AnimalAgent, animalModel)**
* Remove bobby calves at three days
"""

function bobby_cull!(AnimalAgent, animalModel)

    if AnimalAgent.sex == :M && AnimalAgent.age > 3
        kill_agent!(AnimalAgent, animalModel)
        #println("Bobby cull!")
    end

end