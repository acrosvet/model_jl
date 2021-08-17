function endTreatment!(CalfAgent, calfModel)
#Define the endpoint of treatment
        if CalfAgent.treatment != :T && return
        elseif CalfAgent.days_treated ≥ calfModel.treatment_duration
            CalfAgent.treatment = :PT
        end
end