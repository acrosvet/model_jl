function farm_step!(FarmAgent, farmModel)

    

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.traded == false
        daytrader!(FarmAgent)
        farm_trader!(FarmAgent, farmModel)
    end
    
    

end