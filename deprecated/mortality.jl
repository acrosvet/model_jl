"""
mortality()
"""
function mortality!(CalfAgent, calfModel)
   if CalfAgent.status == :IS && (rand(calfModel.rng) < calfModel.mortalityRateSens)
      kill_agent!(CalfAgent, calfModel)
   else 
    CalfAgent.inf_days_is += 1*time_resolution
    end

    if CalfAgent.status == :IR && (rand(calfModel.rng) < calfModel.mortalityRateRes)
        kill_agent!(CalfAgent, calfModel)
    else
        CalfAgent.inf_days_ir += 1*time_resolution
    end

end
