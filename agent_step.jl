#Update agent parameters for each time step
function agent_step!(CalfAgent, calfModel)
    #periodic_position!(CalfAgent, calfModel) #Constrain position twice daily.
    move_agent!(CalfAgent, calfModel, calfModel.timestep) #Move the agent in space
    treatment!(CalfAgent, calfModel) #Introduce treatment
    treatment_effect!(CalfAgent) #Effect of treatment on transmission.
    endTreatment!(CalfAgent, calfModel)
    retreatment!(CalfAgent, calfModel) #Effect of retreatment
    mortality!(CalfAgent, calfModel) #Introduce mortality
    recover!(CalfAgent, calfModel) # Introduce recovery
    carrierState!(CalfAgent, calfModel) #Introduce a carrier state
    update_agent!(CalfAgent) #Apply the update_agent function
end