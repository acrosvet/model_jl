        # Required packages 
        include("packages.jl")

        include("agent_types.jl")

        # Def - time resolution ------------

        const time_resolution = 1
        
        # Include the bacterial model 
        @everywhere include("bacterial_model.jl")
 
        # Include the animal_model
        include("animal_model.jl")