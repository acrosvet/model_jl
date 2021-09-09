"""
**wean!(AnimalAgent)***

* Wean animal agents to weaned status

"""
function wean!(AnimalAgent)
    if AnimalAgent.stage == :C
        if AnimalAge ≥ rand(animalModel.rng, truncated(Poisson(60), 55, 70))
            AnimalAgent.stage = :W
        end
    end
end