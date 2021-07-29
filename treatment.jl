function treatment!(CalfAgent, calfModel)
    # Assign a treatment status
    if (CalfAgent.status != :IS || CalfAgent.status != :IR) && return
    elseif CalfAgent.treatment == :T && return
    elseif (rand(CalfModel.rng) < calfModel.treatment_prob)
        CalfAgent.treatment = :T
    end
#Define the endpoint of treatment
    if CalfAgent.treatment != :T && return
    elseif CalfAgent.days_treated ≥ calfModel.treatment_duration
        CalfAgent.treatment = :PT
    end

end
    
