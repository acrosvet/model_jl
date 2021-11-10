module bacterial

using Agents
using CSV
using DataFrames
using Distributions
using Dates
using Random
using DrWatson

export initialiseBacteria, bact_carrier!, populate_empty!, bacterial_population!, treatment!, bact_export_headers, fitness!, infection!, invasion!, bact_plasmid_transfer!, bact_recovery!, stress!, export_bacto_position!, export_bacto_data!

# Define agent =====================================================================================

"""
Agent type - BacterialAgent
"""
mutable struct BacterialAgent <: AbstractAgent
    id::Int64
    pos::NTuple{2, Int}
    status::Symbol
    strain::Int64
    strain_status::Symbol
    fitness::Float64
end

# Bacterial ABM ======================================================================================

"""
Bacterial ABM - All animals
"""
function initialiseBacteria(

       
    nstrains = rand(4:10),
    r_strain = rand(1:nstrains),
    status = :S,
    resistant_pop = 0;
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
    rng::MersenneTwister = MersenneTwister(42))

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
        add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
    end


   for n in 1:min_resistant
        strain = nstrains + 1
        pos = (rand(1:dims),rand(1:dims))
        strain_status = :R
        fitness = mean(bacterialModel.fitnesses)
        status = :R
            add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
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
                add_agent_single!(bacterialModel, status, strain, strain_status, fitness)
        end
    end


    return bacterialModel

end


# Agent stepping functions #########################################################################################
# Bacterial carrier state =============================================================

"""
bact_carrier - bacterial carrier actions
"""
function bact_carrier!(bacterialModel)

    if bacterialModel.total_status == :CS
        bacterialModel.min_sensitive = Int(floor(0.1*length(allagents(bacterialModel))))
    elseif bacterialModel.total_status == :CR
        bacterialModel.min_resistant = Int(floor(0.1*length(allagents(bacterialModel))))
    end

end

# Empty neighbours ======================================================================

"""
bact_empty_neighbous!
Fill empty grid spaces left by treatment
"""
function populate_empty!(BacterialAgent, bacterialModel)

    if random_empty(bacterialModel) != Nothing 
    
        # Fill in empty positions with bacteria
    
    #Set the agent position
    
        agent_x = BacterialAgent.pos[1]
        agent_y = BacterialAgent.pos[2]
    
    # Create an empty vector of nearby positions    
        adjacent_positions = []
    
    #Push all adjacent positions to the vector
        pos_1 = (agent_x + 1, agent_y)
        push!(adjacent_positions, pos_1)
        pos_2 = (agent_x - 1, agent_y)
        push!(adjacent_positions, pos_2)
        pos_3 = (agent_x, agent_y +1)
        push!(adjacent_positions, pos_3)
        pos_4 = (agent_x, agent_y - 1)
        push!(adjacent_positions, pos_4)
        pos_5 = (agent_x -1, agent_y +1)
        push!(adjacent_positions, pos_5)
        pos_6 = (agent_x - 1, agent_y - 1)
        push!(adjacent_positions, pos_6)
        pos_7 = (agent_x +1, agent_y + 1)
        push!(adjacent_positions, pos_7)
        pos_8 = (agent_x + 1, agent_y - 1)
        push!(adjacent_positions, pos_8)
    
    # Iterate through the empty positions created by treatment, populating them with resistant bacteria if treatment is still ongoing.
    @async Threads.@threads for i in 1:length(adjacent_positions)
            if (adjacent_positions[i][1] <= bacterialModel.dim && adjacent_positions[i][1] > 0) && (adjacent_positions[i][2] <= bacterialModel.dim && adjacent_positions[i][2] > 0)
                if isempty(adjacent_positions[i], bacterialModel)
                    if bacterialModel.days_treated != 0
                        strain = bacterialModel.r_strain
                        status = :R
                        fitness = bacterialModel.fitnesses[bacterialModel.r_strain]
                        strain_status = :R
                    else
                        strain = BacterialAgent.strain
                        status = BacterialAgent.status
                        fitness = BacterialAgent.fitness
                        strain_status = BacterialAgent.strain_status
                    end
                    pos = adjacent_positions[i]
                    if rand(bacterialModel.rng) < 0.5
                        add_agent!(pos, bacterialModel,status, strain, strain_status, fitness)
                    end
                end
            end
        end
    
    end 
    end


# Population counts ======================================================================

"""
bacterial_population!
Get counts of bacterial types
"""
function bacterial_population!(bacterialModel)
    
    number_susceptible =  [a.status == :S for a in allagents(bacterialModel)]
    number_susceptible = sum(number_susceptible)
    bacterialModel.num_susceptible = number_susceptible

    number_sensitive = [a.status == :IS for a in allagents(bacterialModel)]
    number_sensitive = sum(number_sensitive)
    bacterialModel.num_sensitive = number_sensitive

    number_resistant = [a.status == :R for a in allagents(bacterialModel)]
    number_resistant = sum(number_resistant)
    bacterialModel.num_resistant = number_resistant

    resistant_prop = number_resistant/(number_resistant + number_sensitive + number_susceptible)
    sensitive_prop = number_sensitive/(number_resistant + number_sensitive + number_susceptible)
    susceptible_prop = number_susceptible/(number_resistant + number_sensitive + number_susceptible)



    bacterialModel.resistant_pop = resistant_prop
    bacterialModel.sensitive_pop = sensitive_prop
    bacterialModel.susceptible_pop = susceptible_prop
    

 end

 # Treatment ==========================================================

"""
treatment!
Bacterial behaviour during treatment
"""

function treatment!(BacterialAgent, bacterialModel)
        
    num_sensitive = bacterialModel.num_sensitive

    num_sensitive = [a.status == :IS for a in allagents(bacterialModel)]
    num_sensitive = sum(num_sensitive)

    # Turn over agents at each timestep

    if bacterialModel.days_treated > 0 && bacterialModel.days_recovered
        if bacterialModel.total_status == :IR || bacterialModel.total_status == :IS
            if BacterialAgent.status == :IS
                if rand(animalModel.rng) < ℯ^(-bacterialModel.days_treated/10)
                    if bacterialModel.total_status == :CS && num_sensitive > bacterialModel.min_sensitive
                        kill_agent!(BacterialAgent, bacterialModel)
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
end

 #Export headers

"""
bact_export_headers
Define file header for export
"""
function bact_export_headers()
        bacto_header = DataFrame(
        animal_id = 0, 
        step = 0,
        sensitive = 0,
        resistant = 0,
        susceptible = 0,
        resistant_proportion = 0,
        sensitive_proportion = 0,
        total_status = 0,
        days_exposed = 0,
    )


    bacto_output = open("./export/bacterial_model_run.csv","w")
                CSV.write(bacto_output, bacto_header, delim = ",", append = true, header = true)
            close(bacto_output)


    bacterial_posheader = DataFrame(
        step = 0,
        id = 0,
        bactostatus = 0,
        strain = 0,
        x = 0,
        y =0)

    bacto_posoutput = open("./export/bacterial_positions.csv","w")
    CSV.write(bacto_posoutput, bacterial_posheader, delim = ",", append = true, header = true)
    close(bacto_posoutput)
end

# fitness =====================================================================

"""
fitness!
Competition between bacteria with different fitnesses
"""
function fitness!(BacterialAgent, bacterialModel)

    possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))
    num_contacts = length(possible_interactions) 
    status_agent = BacterialAgent.status
    if length(possible_interactions) > 0
        @async Threads.@threads  for i in 1:length(possible_interactions)
            if haskey(bacterialModel.agents, possible_interactions[i])
                interacting_agent = bacterialModel[possible_interactions[i]]
                interacting_id = interacting_agent.id
                num_contacts = length(possible_interactions)
                status_agent = BacterialAgent.status
                interacting_fitness = interacting_agent.fitness

                if BacterialAgent.fitness > interacting_fitness
                    #if rand(bacterialModel.rng) < 0.05
                    if interacting_agent.status == :R && (bacterialModel.num_resistant > bacterialModel.min_resistant) 
                        if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                bacterialModel[interacting_id].strain = BacterialAgent.strain
                                bacterialModel[interacting_id].status = BacterialAgent.status
                                bacterialModel.num_resistant -=1 
                        end
                    elseif interacting_agent.status == :S && (bacterialModel.num_susceptible > bacterialModel.min_susceptible) 
                        if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                            bacterialModel[interacting_id].strain = BacterialAgent.strain
                            bacterialModel[interacting_id].status = BacterialAgent.status
                            bacterialModel.num_susceptible -= 1
                        end
                    end
                end
            end
        end
    end

end


# infection =========================================================================================================================

"""
infection!
Determine bacterial dynamics when host infected
"""
function infection!(BacterialAgent, bacterialModel)

    #if bacterialModel.num_susceptible > bacterialModel.min_susceptible
    
    
        if bacterialModel.total_status == :ES && bacterialModel.days_exposed == 1
            pathogenic_strain = 1
            while pathogenic_strain == bacterialModel.r_strain
                pathogenic_strain += 1
            end
            bacterialModel.strain_statuses[pathogenic_strain] = :IS
            if BacterialAgent.id % 3 == 0 && BacterialAgent.strain != bacterialModel.r_strain
                #if (num_susceptible > bacterialModel.min_susceptible) && (bacterialModel.num_resistant > bacterialModel.min_resistant)
                    BacterialAgent.strain = pathogenic_strain
                    BacterialAgent.status = :IS
                    BacterialAgent.fitness = bacterialModel.fitnesses[pathogenic_strain]*rand(bacterialModel.rng, 0.95:0.01:1.1)
                #end
            end
        elseif bacterialModel.total_status == :ER && bacterialModel.days_exposed == 1
            r_strain = bacterialModel.r_strain
            if BacterialAgent.id % 3 == 0
                #if (num_susceptible > bacterialModel.min_susceptible) && (bacterialModel.num_resistant > bacterialModel.min_resistant)
                    BacterialAgent.strain = r_strain
                    BacterialAgent.status = :R
                    BacterialAgent.fitness = bacterialModel.fitnesses[r_strain]*rand(bacterialModel.rng, 0.95:0.01:1.1)
                #end
            end
        end
    #end
    end

    
# Invasion ===========================================================================================================

"""
invasion!
Competition between infected and susceptible bacteria
"""
function invasion!(BacterialAgent, bacterialModel)

    # If the animal is exposed but not recovered, pathogenic bacteria can outcompete existing bacteria.
       if bacterialModel.days_exposed != 0 && bacterialModel.days_recovered == 0
           #println("evaluating")
               possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))#Determine the neighbours of each agent
               num_contacts = length(possible_interactions)#Determine the number of contacts
               status_agent = BacterialAgent.status#Determine the status of the agent
           
           if length(possible_interactions) > 0 #If there are interactions
               @async Threads.@threads for i in 1:length(possible_interactions)
                   if haskey(bacterialModel.agents, possible_interactions[i])
                       interacting_agent = bacterialModel[possible_interactions[i]]
                       interacting_id = interacting_agent.id
                       num_contacts = length(possible_interactions) #Iterate through them
                       status_agent = BacterialAgent.status
                       interacting_status = interacting_agent.status
   
                       if interacting_status == :S
                           if BacterialAgent.status == :IS && bacterialModel.total_status == :ES #Sensitive agents compete with pathogenic agents
                           # println("Condition 1 met")
                                   if rand(bacterialModel.rng) < 0.5
                                       if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                           if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                                               #println("IS invasion!")
                                               bacterialModel[interacting_id].strain = BacterialAgent.strain
                                               bacterialModel[interacting_id].status = BacterialAgent.status
                                               bacterialModel.num_susceptible -= 1
                                           end
                                       end
                                   end
                           elseif BacterialAgent.status == :R && bacterialModel.total_status == :ER
                               if rand(bacterialModel.rng) < 0.5    
                                   if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                       if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                                           #println("IR invasion")
                                           bacterialModel[interacting_id].strain = BacterialAgent.strain
                                           bacterialModel[interacting_id].status = BacterialAgent.status
                                           bacterialModel.num_susceptible -= 1
                                       end
                                   end
                               end
                           end
                       end
                   end
               end
           end
   
       end
   
   end

# Plasmid transfer ============================================

"""
bact_plasmid_transfer!
Horizontal transfer of resistance between bacteria
"""
function bact_plasmid_transfer!(BacterialAgent, bacterialModel)


    possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))

    if length(possible_interactions) > 0

    num_contacts = length(possible_interactions)
    status_agent = BacterialAgent.status
    if length(possible_interactions) > 0
        @async Threads.@threads for i in 1:length(possible_interactions)
            if haskey(bacterialModel.agents, possible_interactions[i])
            interacting_agent = bacterialModel[possible_interactions[i]]
            interacting_id = interacting_agent.id
            num_contacts = length(possible_interactions)
            status_agent = BacterialAgent.status
            interacting_status = interacting_agent.status

            if BacterialAgent.status == :R && (interacting_status == :IS || interacting_status == :S)
                if rand(bacterialModel.rng) < 0.005
                    if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                        if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                            bacterialModel[interacting_id].strain = BacterialAgent.strain
                            bacterialModel[interacting_id].status = BacterialAgent.status
                            bacterialModel[interacting_id].fitness = BacterialAgent.fitness
                            if interacting_status == :S
                                bacterialModel.num_susceptible -= 1
                            elseif interacting_status == :IS
                                bacterialModel.num_sensitive -= 1
                            end
                        end
                    end
                end
            end
        end
        end
    end

end

end

#Recovery ======================================================================
"""
bact_recovery!
Bacterial dynamics during the recovery phase.
"""
function bact_recovery!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :recovered || bacterialModel.total_status == :RR || bacterialModel.total_status == :RS
            if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_recovered/50)
                if (bacterialModel.num_resistant > bacterialModel.min_resistant) && BacterialAgent.status == :R
                    if haskey(bacterialModel.agents, BacterialAgent.id)
                        kill_agent!(BacterialAgent, bacterialModel)
                        bacterialModel.num_resistant -= 1
                    end
                elseif BacterialAgent.status == :IS 
                    if haskey(bacterialModel.agents, BacterialAgent.id)
                        kill_agent!(BacterialAgent, bacterialModel)
                        bacterialModel.num_sensitive -= 1
                    end
                end
            end
    end

end

# stress ==========================================================================
"""
stress!
bacterial response to host stress
"""
function stress!(bacterialModel)
    if bacterialModel.stress == true && bacterialModel.total_status == :CS
        bacterialModel.total_status == :ES
        bacterialModel.carrier = :yes
    elseif bacterialModel.stress == true && bacterialModel.total_status == :CR
        bacterialModel.total_status == :ER 
        bacterialModel.carrier = :yes
    end
end

# Export bacterial data ==============================================================

"""
export_bacto_position!
Write bacterial position to file
"""
function export_bacto_position!(BacterialAgent, bacterialModel)
    bacterial_posdata = DataFrame(
        step = bacterialModel.step,
        id = BacterialAgent.id,
        bactostatus = BacterialAgent.status,
        strain = BacterialAgent.strain,
        x = BacterialAgent.pos[1],
        y = BacterialAgent.pos[2])
    bacto_posoutput = open("./export/bacterial_positions.csv","a")
    CSV.write(bacto_posoutput, bacterial_posdata, delim = ",", append = true, header = false)
    close(bacto_posoutput)
end

"""
export_bacto_data!
Expert bacterial state attributes
"""

function export_bacto_data!(bacterialModel)
    bacterial_data = DataFrame(
        animal_id = bacterialModel.animalno,
        step = bacterialModel.step,
        sensitive = bacterialModel.num_sensitive,
        resistant = bacterialModel.num_resistant,
        susceptible = bacterialModel.num_susceptible,
        resistant_proportion = bacterialModel.resistant_pop,
        sensitive_proportion = bacterialModel.sensitive_pop,
        total_status = bacterialModel.total_status,
        days_exposed = bacterialModel.days_exposed)
    bacto_output = open("./export/bacterial_model_run.csv","a")
    CSV.write(bacto_output, bacterial_data, delim = ",", append = true, header = false)
    close(bacto_output)
end

# Agent stepping function ====================================
"""
bact_agent_step!
bacterial agent stepping function
"""
function bact_agent_step!(BacterialAgent, bacterialModel)


     bact_recovery!(BacterialAgent, bacterialModel)#Recovery after infection
     infection!(BacterialAgent, bacterialModel)#When exposed, populate with pathogenic bacteria
     invasion!(BacterialAgent, bacterialModel)#When exposed, competition between non-pathogenic and pathogenic bacteria ensues
     bact_treatment_response!(BacterialAgent, bacterialModel)#Set response to treatment
     populate_empty!(BacterialAgent, bacterialModel) # Populate empty spaces left by treatment
     fitness!(BacterialAgent, bacterialModel)#Fitness competitions between adjacent bacteria
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)#Plasmid transfer between adjacent bacteria
    # export_bacto_position!(BacterialAgent, bacterialModel)


end
   

# Model stepping function --------------------------------------------
"""
bact_model_step!
bacterial model stepping function
"""
function bact_model_step!(bacterialModel)
    bact_carrier!(bacterialModel)
    bacterial_population!(bacterialModel)
end 
 
end