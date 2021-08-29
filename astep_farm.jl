function farm_agent_step!(FarmAgent, farmModel)
    farm_update_agent!(FarmAgent, farmModel)
    contact!(FarmAgent, farmModel)
    #transmit!(agent, model)
end