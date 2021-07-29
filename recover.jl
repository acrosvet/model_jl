
"""
function(recover)
"""
function recover!(CalfAgent, calfModel)
    if (CalfAgent.inf_days_is ≥ 5*time_resolution && CalfAgent.status == :IS) && (rand(calfModel.rng) < calfModel.sponrec_is)
        CalfAgent.status = :RS
    elseif CalfAgent.inf_days_ir ≥ 5*time_resolution && CalfAgent.status == :IR && (rand(calfModel.rng) < calfModel.sponrec_ir)
        CalfAgent.status = :RR
    end
end
