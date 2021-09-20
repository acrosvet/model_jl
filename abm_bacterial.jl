const time_units = 1



function initialisePopulation(

        seed = 42,
        nstrains = rand(4:10),
        r_strain = rand(1:nstrains),
        status = :S,
        resistant_pop = 0,
        rng = MersenneTwister(42);
        nbact::Int64,
        total_status::Symbol = AnimalAgent.status,
        timestep::Float64 = 1.0,
        days_treated::Int = AnimalAgent.days_treated,
        age::Int = AnimalAgent.age,
        days_exposed::Int = AnimalAgent.days_exposed


    )

    agentSpace = GridSpace((100, 100); periodic = false)

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

    # Set up the initial parameters
    for n in 1:nbact
        strain = rand(1:nstrains)
        pos = (1,1)
        strain_status = strain_statuses[strain]
        fitness = bact_fitnesses[strain]
        status = strain_status
        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
        add_agent_single!(agent, bacterialModel)
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

    # Transfer of sensitive infections

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

# Plasmid transfer between neighbouring agents

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

    # Bacterial sensescence-----------------------

    function treatment!(BacterialAgent, bacterialModel)
        
        # Turn over agents at each timestep

        if bacterialModel.days_treated > 0
            if bacterialModel.total_status == :IR || bacterialModel.total_status == :IS
                if BacterialAgent.status == :IS
                    if rand(animalModel.rng) < ℯ^(-bacterialModel.days_treated/10)
                        kill_agent!(BacterialAgent, bacterialModel)
                        bacterialModel.r_strain == 0 ? bacterialModel.r_strain = max(bacterialModel.nstrains) + 1 : bacterialModel.r_strain = bacterialModel.r_strain
                        strain = bacterialModel.r_strain
                        pos = BacterialAgent.pos
                        strain_status = bacterialModel.strain_statuses[r_strain]
                        fitness = bacterialModel.fitnesses[r_strain]
                        status = bacterialModel.strain_statuses[r_strain]
                        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
                        add_agent_single!(agent, bacterialModel) 
                    end
                end
            end
        end   
    end

 # Bacterial population function --------------------------

 function bacterial_population!(bacterialModel)
    
    number_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    number_susceptible = sum(number_susceptible)
    bacterialModel.num_susceptible = number_susceptible

    number_sensitive = [a.status == :IS for a in allagents(bacterialModel)]
    number_sensitive = sum(number_sensitive)
    bacterialModel.num_sensitive = number_sensitive

    number_resistant = [a.status == :R for a in allagents(bacterialModel)]
    number_resistant = sum(number_resistant)
    bacterialModel.num_resistant = number_resistant

    resistant_prop = number_resistant/(number_resistant + number_sensitive + number_susceptible)

    bacterialModel.resistant_pop = resistant_prop
    

 end

 function export_bacto_position!(BacterialAgent, bacterialModel)
    bacterial_posdata = DataFrame(
        step = bacterialModel.step,
        id = BacterialAgent.id,
        bactostatus = BacterialAgent.status,
        x = BacterialAgent.pos[1],
        y = BacterialAgent.pos[2])
    bacto_posoutput = open("./export/bacterial_positions.csv","a")
    CSV.write(bacto_posoutput, bacterial_posdata, delim = ",", append = true, header = false)
    close(bacto_posoutput)
    end

 function export_bacto_data!(bacterialModel)
    bacterial_data = DataFrame(
        step = bacterialModel.step,
        sensitive = bacterialModel.num_sensitive,
        resistant = bacterialModel.num_resistant,
        susceptible = bacterialModel.num_susceptible,
        resistant_proportion = bacterialModel.resistant_pop)
    bacto_output = open("./export/bacterial_model_run.csv","a")
    CSV.write(bacto_output, bacterial_data, delim = ",", append = true, header = false)
    close(bacto_output)
    end



     #Update agent parameters for each timestep  
    function bact_model_step!(bacterialModel)
            bacterial_population!(bacterialModel)
            bacterialModel.age += 1
            bacterialModel.step += 1 
            export_bacto_data!(bacterialModel)
    end 
    
    # Define the agent stepping function
    #Update agent parameters for each time step

    function bact_agent_step!(BacterialAgent, bacterialModel)
           # uninfected!(BacterialAgent, bacterialModel)
            bact_transfer_r!(BacterialAgent, bacterialModel)
            bact_transfer_s!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
           # bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)
            export_bacto_position!(BacterialAgent, bacterialModel)
            treatment!(BacterialAgent, bacterialModel)


    end



bacto_header = DataFrame(
    step = 0,
    sensitive = 0,
    resistant = 0,
    susceptible = 0,
    resistant_proportion = 0
)


bacto_output = open("./export/bacterial_model_run.csv","w")
            CSV.write(bacto_output, bacto_header, delim = ",", append = true, header = true)
         close(bacto_output)

bactoMod = initialisePopulation(nbact = 10000, total_status = :IR, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0)

bacterial_posheader = DataFrame(
    step = 0,
    id = 0,
    bactostatus = 0,
    x = 0,
    y =0)
bacto_posoutput = open("./export/bacterial_positions.csv","a")
CSV.write(bacto_posoutput, bacterial_posheader, delim = ",", append = true, header = false)
close(bacto_posoutput)

run!(bactoMod, bact_agent_step!, bact_model_step!, 365)

