const time_units = 1



function initialisePopulation(

        seed = 42,
        nstrains = rand(4:10),
        r_strain = rand(1:nstrains),
        status = :S,
        rng = MersenneTwister(42);
        nbact::Int64,
        total_status::Symbol,
        timestep::Float64,
        days_treated::Int = 0,
        age::Int = 0,
        days_exposed::Int = 0,


    )

    agentSpace = GridSpace((100, 100); periodic = false)
    #agentSpace = ContinuousSpace((1,1), 1; periodic = true)

    bactproperties = @dict(
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
    )

    bacterialModel = AgentBasedModel(BacterialAgent, agentSpace, properties = bactproperties)

    # strain fitness

    r_strain = total_status != :IR ? 0 : r_strain
    println(r_strain)

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


    strain_statuses = fn_strain_status!(nstrains, r_strain)

    println(strain_statuses)

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

    bact_fitnesses = fn_strain_fitness!(strain_statuses, nstrains)

    println(bact_fitnesses)

    header = DataFrame(
        BactNo = 0,
        ResistantStrain = 0,
        bactStrain = 0,
        StrainStatus = 0,
        BactStatus = 0,
    )

#=     output = open("./export/bactinit.csv","a")
    CSV.write(output, header, delim = ";", append = true, header = true)
    close(output)
 =#

    # Set up the initial parameters
    for n in 1:nbact
        strain = rand(1:nstrains)
        pos = (1,1)
        strain_status = strain_statuses[strain]
        fitness = bact_fitnesses[strain]
        status = strain_status
        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
        add_agent_single!(agent, bacterialModel)
        df = DataFrame(
            BactNo = n,
            #BactPos = pos,
            ResistantStrain = r_strain,
            bactStrain = strain,
            StrainStatus = strain_status,
            StrainFitness = fitness,
            BactStatus = status
        )
#=         output = open("./export/bactinit.csv","a")
        CSV.write(output, df, delim = ";", append = true)
        close(output) =#
    end

        return bacterialModel

    end

# Bacterial population of uninfected animals ----------------------

function uninfected!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :S
        for _ in 1:nstrains
            BacteralAgent.strain_status = :S
            BacterialAgent.status = BacterialAgent.strain_status
        end
    end

end

#= # Movement from exposed to infected  -----------------

function exposed_infected!(bacterialModel)
    bacterialModel.days_exposed += 1
    if bacterialModel.total_status == :ES && (bacterialModel.days_exposed ≥ rand(Poisson(4)))
        bacterialModel.total_status = :IS
    elseif bacterialModel.total_status == :ER && (bacterialModel.days_exposed ≥ rand(Poisson(4)))
        bacteriaModel.total_status = :IR
    end
end
 =#

function infected_sensitive!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :IS
        for i in 1:bacterialModel.strains
            if i % 2 == 0
                BacterialAgent.status = :IS 
            else
                BacterialAgent.status = :S
            end
        end
    end

end
 
# Transmission of bacteria between individuals -----------------
    
    function bact_transfer_r!(BacterialAgent, bacterialModel)
        if bacterialModel.total_status == :ER
            bacterialModel.days_exposed += 1
        else return
        end
        
        if bacterialModel.total_status == :ER && bacterialModel.days_exposed == 1
            bacterialModel.r_strain = rand(1:bacterialModel.nstrains) 
            bacterialModel.strain == bacterialModel.r_strain ? BacterialAgent.status = :R : BacterialAgent.status = :IS
        else return
        end


    end

    function bact_transfer_s!(BacterialAgent, bacterialModel)
        if bacterialModel.total_status == :ES
            bacterialModel.days_exposed += 1
        else return
        end
        
        if bacterialModel.total_status == :ES && bacterialModel.days_exposed == 1
            bacterialModel.r_strain = 0
            BacterialAgent.status == :IS
            bacterialModel.strain == bacterialModel.r_strain ? BacterialAgent.status = :R : BacterialAgent.status == :IS 
        else return
        end


    end


    function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if BacterialAgent.status == :R && neighbor.status == :IS
                if rand(bacterialModel.rng) < 1e-2/time_units
                    neighbor.status = BacterialAgent.status
                    neighbor.strain = BacterialAgent.strain
                    
                end
            end
        end
    end

    function bact_treatment_response!(BacterialAgent, bacterialModel)

        res = bact_response(bacterialModel)/time_units

        if (bacterialModel.days_treated > 0 && BacterialAgent.status == :IS)
            if res/100 > rand(bacterialModel.rng)
                        BacterialAgent.status = :R
                        BacterialAgent.strain = bacterialModel.r_strain
                    end
       else 
                    return
        end



    end




    # Define the agent updating function

    # Define the treatment response function

    function bact_response(bacterialModel)
        timevar = (bacterialModel.days_treated)/time_units
        res = (100*ℯ^(-0.2/timevar))/(1 + ℯ^(-0.2/timevar))
        return res/time_units
    end

    # 

 
     #Update agent parameters for each timestep  
    function bact_update_agent!(BacterialAgent, bacterialModel)
            bacterialModel.age += 1
    end 
    
    # Define the agent stepping function
    #Update agent parameters for each time step

    function bact_agent_step!(BacterialAgent, bacterialModel)
           # uninfected!(BacterialAgent, bacterialModel)
            bact_transfer_r!(BacterialAgent, bacterialModel)
            bact_transfer_s!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)

#=             header = DataFrame(
                AgentId = 0,
                AgentStatus = 0,
                ModelStep = 0
            )
 =#
#=             output = open("./export/bact_agent_step.csv","a")
            CSV.write(output, header, delim = ";", append = true, header = true)
            close(output)

            df = DataFrame(
               AgentID = BacterialAgent.id,
                AgentStatus = BacterialAgent.status,
                ModelStep = bacterialModel.age
            )

            output = open("./export/bact_agent_step.csv","a")
            CSV.write(output, df, delim = ";", append = true)
            close(output)
 =#

    end


#bactoMod = initialisePopulation(nbact = 10000, total_status = :IR, timestep = 1.0)

#step!(bactoMod, bact_agent_step!,10)

