        # Required packages 
        include("packages.jl")

        include("agent_types.jl")

        # Def - time resolution ------------

        const time_resolution = 1
            
        include("bacterial_model.jl")
        include("animal_model.jl")