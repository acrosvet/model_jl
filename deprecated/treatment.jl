function treatment!(CalfAgent, calfModel)
    # Assign a treatment status
    if (CalfAgent.status != :IS && CalfAgent.status != :IR) && return
    elseif CalfAgent.treatment == :U && (rand(calfModel.rng) < calfModel.treatment_prob)
        CalfAgent.treatment = :T
    end

end
    
