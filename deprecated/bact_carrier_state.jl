function bact_carrier!(bacterialModel)

    if bacterialModel.total_status == :CS
        bacterialModel.min_sensitive = Int(floor(0.1*length(allagents(bacterialModel))))
    elseif bacterialModel.total_status == :CR
        bacterialModel.min_resistant = Int(floor(0.1*length(allagents(bacterialModel))))
    end

end
