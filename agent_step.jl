#Update agent parameters for each time step
function agent_step!(CalfAgent, calfModel)
    move_agent!(CalfAgent, calfModel, calfModel.timestep) #Move the agent in space
    update_agent!(CalfAgent) #Apply the update_agent function
    treatment!(CalfAgent, calfModel) #Introduce treatment
    endTreatment!(CalfAgent, calfModel)
    mortality!(CalfAgent, calfModel) #Introduce mortality
    recover!(CalfAgent, calfModel) # Introduce recovery
    
end