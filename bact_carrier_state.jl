function bact_carrier!(bacterialModel)

    if bacterialModel.total_status == :IS
        if bacterialModel.days_recovered == 5 && rand(bacterialModel.rng) < 0.05
            bacterialModel.total_status = :CS
            bacterialModel.carrier = :yes
        elseif bacterialModel.days_recovered == 5 && bacterialModel.carrier == :yes
            bacterialModel.total_status = :CS
        end
    elseif bacterialModel.total_status == :IR
        if bacterialModel.days_recovered == 5 && rand(bacterialModel.rng) < 0.05
            bacterialModel.total_status = :CR
            bacterialModel.carrier = :yes
        elseif bacterialModel.days_recovered == 5 && bacterialModel.carrier == :yes
            bacterialModel.total_status = :CR
        end
    end

    if bacterialModel.total_status == :CS
        bacterialModel.min_sensitive = Int(floor(0.1*length(allagents(bacterialModel))))
    elseif bacterialModel.total_status == :CR
        bacterialModel.min_resistant = Int(floor(0.1*length(allagents(bacterialModel))))
    end

end
