const time_units = 1



function initialiseBacteria(

       
        nstrains = rand(4:10),
        r_strain = rand(1:nstrains),
        status = :S,
        resistant_pop = 0;
        #rng = MersenneTwister(seed);
        dims::Int = 100,
        animalno::Int = AnimalAgent.id,
        nbact::Int64,
        total_status::Symbol = AnimalAgent.status,
        timestep::Float64 = 1.0,
        days_treated::Int = AnimalAgent.days_treated,
        age::Int = AnimalAgent.age,
        days_exposed::Int = AnimalAgent.days_exposed,
        days_recovered::Int = AnimalAgent.days_recovered,
        stress::Bool = AnimalAgent.stress,
        seed::Int = 42,
        rng::MersenneTwister = MersenneTwister(42)


    )

    agentSpace = GridSpace((dims, dims); periodic = false)

    bactproperties = @dict(
        step = 0,
        nbact,
        status,
        nstrains,
        timestep,
        r_strain,
        days_treated,
        total_status,
        age,
        days_exposed,
        rng = rng,
        resistant_pop = 0,
        sensitive_pop = 0,
        susceptible_pop = 0,
        num_sensitive = 0,
        num_resistant = 0,
        num_susceptible = 0,
        fitnesses = [],
        strain_statuses = [],
        dims,
        days_recovered,
        carrier = :no,
        min_sensitive = 0,
        min_resistant = Int(floor(0.01*nbact)),
        min_susceptible = Int(floor(0.1*nbact)),
        stress,
        animalno,
        seed,
        dim = dims
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


    strain_status = (strain == r_strain) ? :R : :S



    function fn_strain_fitness!(strain_statuses, nstrains)
        bact_fitnesses = []
        for i in 1:nstrains
        strain_status = strain_statuses[i]
        if strain_status == :R
           fitness =  1 - rand(Distributions.Beta(1,10),1)[1]
           push!(bact_fitnesses, fitness)
        else
            fitness  = 1 - rand(Distributions.Beta(1,10),1)[1]
            push!(bact_fitnesses, fitness)
        end
    end
    return bact_fitnesses
    end

    bacterialModel.fitnesses = bact_fitnesses = fn_strain_fitness!(strain_statuses, nstrains)

    # set a small subpopulation of resistant bacteria

    if bacterialModel.total_status == :IS
        min_sensitive = Int(floor(rand(0.5:0.01:0.6)*nbact))
    else
        min_sensitive = 0
    end

    if bacterialModel.total_status == :IR
        min_resistant = Int(floor(rand(0.5:0.01:0.6)*nbact))
    else
        min_resistant = bacterialModel.min_resistant
    end



    # Set up the initial parameters
     for n in 1:(nbact - min_resistant - min_sensitive)
        strain = rand(1:nstrains)
        pos = (rand(1:dims),rand(1:dims))
        strain_status = strain_statuses[strain]
        fitness = bact_fitnesses[strain]
        status = strain_status
        #agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
        #if isempty(pos, bacterialModel)
            add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
        #end
        #add_agent_single!(agent, bacterialModel)
    end


       for n in 1:min_resistant
            strain = nstrains + 1
            pos = (rand(1:dims),rand(1:dims))
            strain_status = :R
            fitness = mean(bacterialModel.fitnesses)
            status = :R
            #agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
            #add_agent_single!(agent, bacterialModel)
            #if isempty(pos, bacterialModel)
                add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
            #end
           # println("Added agent")
        end

        if min_sensitive != 0
            for n in 1:min_sensitive
                pathogenic_strain = 1
                while pathogenic_strain == bacterialModel.r_strain
                    pathogenic_strain += 1
                end
                strain = pathogenic_strain
                pos = (rand(1:dims),rand(1:dims))
                strain_status = :IS
                fitness = bacterialModel.fitnesses[pathogenic_strain]
                status = :IS
                #agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
                #add_agent_single!(agent, bacterialModel)
                #if isempty(pos, bacterialModel)
                    add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
                #end
               # println("Added agent")
            end
        end


        return bacterialModel

    end



