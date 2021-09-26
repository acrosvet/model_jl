"""
 daytrader!(FarmAgent, animalModel)

 * Selects animals to trade from the animalModel of a FarmAgent to the animalModel of another FarmAgent


"""
function daytrader!(AnimalAgent, animalModel)
   io = open("output.txt", "a")
   # Determine if a farm needs agents traded to it:


   # Determine what animals can be traded based on an assigned status
   has_stage(AnimalAgent, status) = AnimalAgent.trade_status == status
   
   #Primitive function, decide to trade based on status
   is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
   
    # Select a number to be traded
   num_traded = abs(animalModel.tradeable_stock)
   
   num_traded > 15 ? 15 : num_traded

   # Clear the to trade list from last step
   animalModel.sending = [] 


   # Put agents in the sending container according to number
   for animal in 1:num_traded
        
        # Select a random agent from the eligible list of agents
       traded_agent = random_agent(animalModel, is_traded(true))

       # Break the function if the pushed agent doesn't exist.
       if typeof(traded_agent) == Nothing
        break
       end
       #Push that to the sending field in the animalModel
       push!(animalModel.sending, traded_agent)


   end        
#=    println("The length of the sending vector is: \n")
   println(length(animalModel.sending))
   println("The length of the receiving vector is: \n")
   println(length(animalModel.receiving)) =#

# Create a vector, received stock, which tracks the animals that have been added to the farm

received_stock = []

# If there are animals waiting in the receiving vector, then we iteratively add those to the animalModel
if length(animalModel.receiving) != 0
   for i in 1:length(animalModel.receiving)
           pos = animalModel.receiving[i].pos
           status = animalModel.receiving[i].status
           age = animalModel.receiving[i].age
           βᵣ = animalModel.receiving[i].βₛ
           βₛ = animalModel.receiving[i].βᵣ
           inf_days = animalModel.receiving[i].inf_days
           days_exposed = animalModel.receiving[i].days_exposed
           days_carrier = animalModel.receiving[i].days_carrier
           treatment = animalModel.receiving[i].treatment
           days_treated = animalModel.receiving[i].days_treated
           since_tx = animalModel.receiving[i].since_tx
           bactopop_r = animalModel.receiving[i].bactopop_r
           bactopop_is = animalModel.receiving[i].bactopop_is
           submodel = animalModel.receiving[i].submodel
           stage = animalModel.receiving[i].stage
           dim = animalModel.receiving[i].dim
           days_dry = animalModel.receiving[i].days_dry
           trade_status = :traded
           agenttype = animalModel.receiving[i].agenttype
           lactation = animalModel.receiving[i].lactation
           pregstat = animalModel.receiving[i].pregstat
           dic = animalModel.receiving[i].dic
           stress = animalModel.receiving[i].stress
           sex = animalModel.receiving[i].sex
           calving_season = animalModel.receiving[i].calving_season
           days_recovered = animalModel.receiving[i].days_recovered
           add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)            
           write(io,"Agent traded\n")
           push!(received_stock, animalModel.receiving[i])

   end
end
# Remove the received animals from the receiving container


while length(received_stock) != 0
   pop!(received_stock)
   pop!(animalModel.receiving)
end

if length(received_stock) == 0
   write(io, "Receiving vector cleared \n")
end


close(io)
end