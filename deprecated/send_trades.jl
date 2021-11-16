function send_trades!(animalModel)

   # Determine what animals can be traded based on an assigned status
   has_stage(AnimalAgent, status) = AnimalAgent.trade_status == status
   
   #Primitive function, decide to trade based on status
   is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
   
    # Select a number to be traded
   num_traded = abs(animalModel.tradeable_stock)
   
   #Max trade 15 at one time
   num_traded > 15 ? 15 : num_traded

   # Clear the to trade list from last step
   animalModel.sending = [] 


   # Put agents in the sending container according to number
   @async Threads.@threads for animal in 1:num_traded
        
        # Select a random agent from the eligible list of agents
       traded_agent = random_agent(animalModel, is_traded(true))

       # Break the function if the pushed agent doesn't exist.
       if typeof(traded_agent) == Nothing
        break
       end
       #Push that to the sending field in the animalModel
       push!(animalModel.sending, traded_agent)

       #println(length(animalModel.sending))
   end  

end