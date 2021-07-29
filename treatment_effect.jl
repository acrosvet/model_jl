function treatment_effect!(CalfAgent)
    # During treatment, sensitive calves become less contagious
    if CalfAgent.treatment == :T && CalfAgent.status == :IS
        CalfAgent.βₛ = 0.5(CalfAgent.βₛ)
    # Resistant calves remain unchanged
    elseif CalfAgent.treatment == :T && CalfAgent.status == :IR
        CalfAgent.βᵣ = CalfAgent.βᵣ
    end

end