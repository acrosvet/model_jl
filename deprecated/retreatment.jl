function retreatment!(CalfAgent, calfModel)
    # Assign a treatment status
    if (CalfAgent.status == :IS || CalfAgent.status == :IR)
        if CalfAgent.treatment == :PT && (rand(calfModel.rng) < calfModel.treatment_prob)
            CalfAgent.treatment == :RT 
        else
            CalfAgent.treatment = CalfAgent.treatment
        end
    end

end
    
