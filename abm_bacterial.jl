const time_units = 1



function initialisePopulation(

        seed = 42,
        nstrains = rand(4:10),
        r_strain = rand(1:nstrains),
        status = :S,
        resistant_pop = 0,
        dim = 33,
        rng = MersenneTwister(42);
        nbact::Int64,
        total_status::Symbol = AnimalAgent.status,
        timestep::Float64 = 1.0,
        days_treated::Int = AnimalAgent.days_treated,
        age::Int = AnimalAgent.age,
        days_exposed::Int = AnimalAgent.days_exposed


    )

    agentSpace = GridSpace((33, 33); periodic = false)

    bactproperties = @dict(
        step = 0,
        nbact,
        seed,
        status,
        nstrains,
        timestep,
        r_strain,
        days_treated,
        total_status,
        age,
        days_exposed,
        rng,
        resistant_pop = 0,
        num_sensitive = 0,
        num_resistant = 0,
        num_susceptible = 0,
        fitnesses = [],
        strain_statuses = [],
        dim,
    )

    bacterialModel = AgentBasedModel(BacterialAgent, agentSpace, properties = bactproperties)

    # strain fitness

    r_strain = total_status != :IR ? 0 : r_strain

    strain = 1

    function fn_strain_status!(nstrains, r_strain)
        strain_statuses = []
        for i in 1:nstrains
            if i != r_strain
               strain_status = :S
               push!(strain_statuses, strain_status)
            else
                strain_status = :R
                push!(strain_statuses, strain_status)
            end
        end
        return strain_statuses
    end


    bacterialModel.strain_statuses = strain_statuses = fn_strain_status!(nstrains, r_strain)


    strain_status = (strain == r_strain) ? :R : :IS



    function fn_strain_fitness!(strain_statuses, nstrains)
        bact_fitnesses = []
        for i in 1:nstrains
        strain_status = strain_statuses[i]
        if strain_status == :R
           fitness =  1 - rand(Distributions.Beta(4,20),1)[1]
           push!(bact_fitnesses, fitness)
        else
            fitness  = 1 - rand(Distributions.Beta(1,20),1)[1]
            push!(bact_fitnesses, fitness)
        end
    end
    return bact_fitnesses
    end

    bacterialModel.fitnesses = bact_fitnesses = fn_strain_fitness!(strain_statuses, nstrains)

    # set a small subpopulation of resistant bacteria

    resistant_seed = rand(0.005:0.001:0.01)



    # Set up the initial parameters
    for n in 1:(nbact - Int(floor(resistant_seed*nbact)))
        strain = rand(1:nstrains)
        pos = (1,1)
        strain_status = strain_statuses[strain]
        fitness = bact_fitnesses[strain]
        status = strain_status
        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
        add_agent_single!(agent, bacterialModel)
    end

    for n in 1:Int(floor(resistant_seed*nbact))
        strain = nstrains + 1
        pos = (1,1)
        strain_status = :R
        fitness = mean(bacterialModel.fitnesses)
        status = :R
        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
        add_agent_single!(agent, bacterialModel)
        println("Added agent")
    end

        return bacterialModel

    end



