"""
 daytrader!(FarmAgent, animalModel)

 * Selects animals to trade from the animalModel of a FarmAgent to the animalModel of another FarmAgent


"""
function daytrader!(FarmAgent, animalModel)

   

   # Determine what animals can be traded based on an assigned status
   has_stage(AnimalAgent, status) = AnimalAgent.status == status
   
   #Primitive function, decide to trade based on status
   is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
   
   # Select a number to be traded
   num_traded = rand(1:24)
   
   # Clear the to trade list from last step
   animalModel.sending = []


   # Put agents in the sending container according to number
   for animal in 1:num_traded
        
        # Select a random agent from the eligible list of agents
       traded_agent = random_agent(animalModel, is_traded(:S))

       # Break the function if the pushed agent doesn't exist.
       if typeof(traded_agent) == Nothing
        break
       end
       #Push that to the sending field in the animalModel
       push!(animalModel.sending, traded_agent)

       # If that agent is present in the list of agents, remove it from the sending farm.
      if haskey(animalModel.agents, traded_agent.id) == true

           kill_agent!(traded_agent, animalModel)
           println("Agent removed")
      end 
   end        

if length(animalModel.receiving) != 0
   for i in 1:length(animalModel.receiving)
           pos = Tuple(10*rand(animalModel.rng, 2))
           status = animalModel.receiving[i].status
           age = animalModel.receiving[i].age
           βᵣ = animalModel.receiving[i].βₛ
           βₛ = animalModel.receiving[i].βᵣ
           inf_days_ir = animalModel.receiving[i].inf_days_ir
           inf_days_is = animalModel.receiving[i].inf_days_is
           treatment = animalModel.receiving[i].treatment
           days_treated = animalModel.receiving[i].days_treated
           bactopop = animalModel.receiving[i].bactopop
           submodel = animalModel.receiving[i].submodel
           vel = animalModel.receiving[i].vel
           stage = animalModel.receiving[i].stage
           since_tx = animalModel.receiving[i].since_tx
           dim = animalModel.receiving[i].dim
           days_dry = animalModel.receiving[i].days_dry
           trade_stauts = animalModel.receiving[i].trade_status
           add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status)   
   end
end

end