"""
**bobby_cull!(AnimalAgent, animalModel)**
* Remove bobby calves at three days
"""

function bobby_cull!(AnimalAgent, animalModel)

    if AnimalAgent.sex == :M && AnimalAgent.age > 3
        culling_reason = "Bobby cull!"
        export_culling!(AnimalAgent, animalModel, culling_reason)
        kill_agent!(AnimalAgent, animalModel)
        
    end

end