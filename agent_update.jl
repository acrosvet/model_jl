#Update agent parameters for each timestep  
function update_agent!(CalfAgent)
    CalfAgent.age += 1*time_resolution # Increment age by 1 day
    
    if CalfAgent.treatment == :T 
        CalfAgent.days_treated += 1*time_resolution
    elseif CalfAgent.treatment == :PT
        CalfAgent.since_tx += 1*time_resolution
    end
end
    