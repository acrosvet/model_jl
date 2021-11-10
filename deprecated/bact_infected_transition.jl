function infected_transition!(bacterialModel)
    if bacterialModel.sensitive_pop > 0.5 && bacterialModel.total_status != :recovered
        bacterialModel.total_status = :IS
    elseif bacterialModel.resistant_pop > 0.5 && bacterialModel.total_status != :recovered
        bacterialModel.total_status = :IR
    elseif bacterialModel.total_status != :CS || bacterialModel.total_status != :CR || bacterialModel.total_status != :ER || bacterialModel.total_status != :ES
        bacterialModel.total_status = :S
    end
end