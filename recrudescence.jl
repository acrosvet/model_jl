function recrudescence!(AnimalAgent, animalModel)


if AnimalAgent.days_recovered > Int(floor(rand(animalModel.rng, truncated(Rayleigh(60),(70), (180)))))
    if AnimalAgent.status == :recovered
        AnimalAgent.status = :S
        AnimalAgent.days_recovered = 0
    end
end

if AnimalAgent.dim == rand(animalModel.rng, 0:60) && (AnimalAgent.status == :CR || AnimalAgent.status == :CS)
    if AnimalAgent.status == :CR
        AnimalAgent.status = :IR
    else
        AnimalAgent.status = :IS
    end
end

end