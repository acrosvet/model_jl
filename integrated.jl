using Agents
using Random
using DrWatson
using CSV

# Def - BacterialAgent --------------------------------

    mutable struct BacterialAgent <: AbstractAgent
        id::Int64
        pos::NTuple{2, Int}
        status::Symbol
        strain::Int64
        days_treated::Int
        age::Int
    end

# ABM - Bacteria ---------------------------------------
    include("gridsub.jl")

# Def - CalfAgent --------------------
    mutable struct CalfAgent <: AbstractAgent
        id::Int
        pos::NTuple{2,Float64}
        vel::NTuple{2, Float64}
        age::Int
        status::Symbol
        βₛ::Float64
        βᵣ::Float64
        inf_days_is::Int
        inf_days_ir::Int
        treatment::Symbol
        days_treated::Int
        since_tx::Int
        bactopop::Float64
        submodel::AgentBasedModel
    end

# Def - time resolution ------------


    const time_resolution = 24
    
# ABM - Calf  --------------------

  
    #Define model initialisation functions. 

    function initialiseModel(
        N = 10, #Default number of animals
        seed = 42, #Random seed
        calfProximityRadius = 0.5, #Radius for effective contact
        mortalityRateSens = 0.01/time_resolution, #Mort. (sensitive)
        mortalityRateRes = 0.015/time_resolution, #Mort. (resistant)
        movement = 0.1, #Movement in continuous space
        βᵣ = 0.3/time_resolution, #Beta (resistant) NOT TIME DEPENDENT?!
        βₛ = 0.6/time_resolution, #Beta (sensitive)
        age = 1*time_resolution, #Initial age
        init_is = 5, # Number initially infected sensitive
        init_ir = 1, # Number initially infected resistant
        inf_days_is = 0,
        inf_days_ir = 0,
        sponrec_is = 0.05/time_resolution, #chance of spontaneous recovery IS
        sponrec_ir = 0.04/time_resolution,  #chance of spontaneous recovery IR
        timestep = 1.0, #Set model timestep
        treatment = :U,
        days_treated = 0,
        treatment_prob = 0.3/time_resolution,
        treatment_duration = 5*time_resolution,
        since_tx = 0,
        res_carrier = 0.05/time_resolution,
        sens_carrier = 0.01/time_resolution, 
        bactopop = 0.0,
        submodel = initialisePopulation(),
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace = ContinuousSpace((10,10), 1; periodic = true) #Relatinship to real space?
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        calfProximityRadius,
        mortalityRateSens,
        mortalityRateRes,
        sponrec_ir,
        sponrec_is,
        timestep, 
        treatment_prob,
        treatment_duration, 
        since_tx,
        res_carrier,
        sens_carrier,
        bactopop,
        submodel)# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    calfModel = ABM(CalfAgent, agentSpace, properties = pathogenProperties, rng = MersenneTwister(seed))

    #Define a function to set initial infected status. This gets supplied to the loop describing the initial system state.
    function initial_status(n, init_ir, init_is)
        if n ≤ init_is 
            :IS
        elseif n > init_is && n <= (init_is + init_ir)
            :IR
        elseif n > init_is + init_ir
            :S
        end
    end

    #Define a function parameter to govern the movement of animals in different states

    function initial_velocity(status, movement)
        if status == :S
            sincos(2π*rand(calfModel.rng)) .*movement
        elseif status == :IS
            sincos(2π*rand(calfModel.rng)) .*(movement/2)
        elseif status == :IR
            sincos(2π*rand(calfModel.rng)) .*(movement/2.5)
        elseif status == :M
            (0.0,0.0)
        end
    end


    #Define the initial state of the system. Attributes for each calf in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(calfModel.rng, 2))
        status = initial_status(n, init_ir, init_is)
        age = age
        βᵣ = βᵣ
        βₛ = βₛ
        treatment = treatment
        treatment_prob = treatment_prob
        days_treated = days_treated
        treatment_duration = treatment_duration
        bactopop = 0.0
        submodel = submodel
        vel = initial_velocity(status, movement)
        add_agent!(pos, calfModel, vel, age, status, βᵣ, βₛ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel)
    end

        return calfModel
    end



    calfModel = initialiseModel()
# Utility functions -------------

# Fn - Transmit resistant (Calf) ------------------------
    function transmit_resistant!(a1,a2)
        count(a.status == :IR for a in (a1, a2)) ≠ 1 && return
            infected, healthy = a1.status == :IR ? (a1, a2) : (a2, a1)
    #If a random number is below the transmssion parameter, infect, provided that the contacted animal is susceptible.
            if (rand(calfModel.rng) < infected.βᵣ) && healthy.status == :S
                healthy.status = :IR
            else
                healthy.status = healthy.status
            end

    end

# Fn - Transmit sensitive (Calf) -----------------------    
    function transmit_sensitive!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(calfModel.rng) < infected.βₛ) && healthy.status == :S
            healthy.status = :IS
            # Else we set the status of the healthy animal to IS
        else
            healthy.status = healthy.status
        end
    end

# Fn - Transmit carrier (Calf) ----------------------------    
    function transmit_carrier!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(calfModel.rng) < rand(calfModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
            if healthy.treatment == :PT && (rand(calfModel.rng) < rand(calfModel.rng)*infected.βᵣ)
                healthy.status = :IR
                healthy.inf_days_ir = 0
            else
                healthy.status = :IS
                healthy.inf_days_is = 0
            end
            # Else we set the status of the healthy animal to its existing status
        else
            healthy.status = healthy.status
        end
    end

# Fn - Transmit carrier (Calf) ---------------------------------------    
    function transmit_carrier_is!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(calfModel.rng) < rand(calfModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
            if healthy.treatment == :PT && (rand(calfModel.rng) < rand(calfModel.rng)*infected.βᵣ)
                healthy.status = :IR
                healthy.inf_days_ir = 0
            else
                healthy.status = :IS
                healthy.inf_days_is = 0
            end
            # Else we set the status of the healthy animal to its existing status
        else
            healthy.status = healthy.status
        end
    end

    function transmit_carrier_ir!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :CR for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :CR ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(calfModel.rng) < rand(calfModel.rng)*infected.βᵣ) && (healthy.status == :S || healthy.status == :RS || healthy.status == :RR)
                healthy.status = :IR
                healthy.inf_days_ir = 0
            # Else we set the status of the healthy animal to its existing status
        else
            healthy.status = healthy.status
        end
    end

# Fn - Treatment effect (Calf) -------------------------    
    function treatment_effect!(CalfAgent)
    # During treatment, sensitive calves become less contagious
    if CalfAgent.treatment == :T && CalfAgent.status == :IS
        CalfAgent.βₛ = 0.8(CalfAgent.βₛ)
    # Resistant calves remain unchanged
    elseif CalfAgent.treatment == :T && CalfAgent.status == :IR
        CalfAgent.βᵣ = CalfAgent.βᵣ
    end

    end

# Fn - Bacterial dynamics --------------------

    function bacto_dyno!(CalfAgent)
        if CalfAgent.bactopop > 0.5
            CalfAgent.status = :IR
        else return
        end

    end

# Fn - End of treatment ---------------------------    
function endTreatment!(CalfAgent, calfModel)
    #Define the endpoint of treatment
            if CalfAgent.treatment != :T && return
            elseif CalfAgent.days_treated ≥ calfModel.treatment_duration
                CalfAgent.treatment = :PT
            end
    end

# Fn - start of treatment -------------------------    

function treatment!(CalfAgent, calfModel)
        # Assign a treatment status
        if (CalfAgent.status != :IS && CalfAgent.status != :IR) && return
        elseif CalfAgent.treatment == :U && (rand(calfModel.rng) < calfModel.treatment_prob)
            CalfAgent.treatment = :T
            
        end
    
    end

# Fn - Recovery ------------------------------------------------------    

    function recover!(CalfAgent, calfModel)
        if (CalfAgent.inf_days_is ≥ 5*time_resolution && CalfAgent.status == :IS) && (rand(calfModel.rng) < calfModel.sponrec_is)
            CalfAgent.status = :RS
        elseif CalfAgent.inf_days_ir ≥ 5*time_resolution && CalfAgent.status == :IR && (rand(calfModel.rng) < calfModel.sponrec_ir)
            CalfAgent.status = :RR
        end
    end

# Fn - retreatment ----------------------------------------------------------

    function retreatment!(CalfAgent, calfModel)
        # Assign a treatment status
        if (CalfAgent.status == :IS || CalfAgent.status == :IR)
            if CalfAgent.treatment == :PT && (rand(calfModel.rng) < calfModel.treatment_prob)
                CalfAgent.treatment == :RT 
            else
                CalfAgent.treatment = CalfAgent.treatment
            end
        end

    end

# Fn - Mortality ------------------------------------------------------------    
    function mortality!(CalfAgent, calfModel)
        if CalfAgent.status == :IS && (rand(calfModel.rng) < calfModel.mortalityRateSens)
        kill_agent!(CalfAgent, calfModel)
        else 
        CalfAgent.inf_days_is += 1*time_resolution
        end
    
        if CalfAgent.status == :IR && (rand(calfModel.rng) < calfModel.mortalityRateRes)
            kill_agent!(CalfAgent, calfModel)
        else
            CalfAgent.inf_days_ir += 1*time_resolution
        end
    
    end

# Fn - Bact (agent step) ----------------------------------

    function bact_agent_step!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            bact_update_agent!(BacterialAgent) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)

    end

# Fn - Calf Model Step -------------------------------------

    function model_step!(calfModel)
        #Define the proximity for which infection may occur
        r = calfModel.calfProximityRadius
        for (a1,a2) in interacting_pairs(calfModel, r, :nearest)
            elastic_collision!(a1, a2) #Collison dynamics for each calf
            transmit_sensitive!(a1,a2) #Sensitive transmission function
            transmit_resistant!(a1,a2) #Resistant transmission function
            transmit_carrier_is!(a1,a2)
            transmit_carrier_ir!(a1,a2)
            
        end
    end

# Fn - Calf Agent Step -----------------------------------------------------------    

    function agent_step!(CalfAgent, calfModel)
        #resist!(CalfAgent)
        bacto_dyno!(CalfAgent)
        move_agent!(CalfAgent, calfModel, calfModel.timestep) #Move the agent in space
        treatment!(CalfAgent, calfModel) #Introduce treatment
        treatment_effect!(CalfAgent) #Effect of treatment on transmission.
        endTreatment!(CalfAgent, calfModel)
        retreatment!(CalfAgent, calfModel) #Effect of retreatment
        mortality!(CalfAgent, calfModel) #Introduce mortality
        recover!(CalfAgent, calfModel) # Introduce recovery
        carrierState!(CalfAgent, calfModel) #Introduce a carrier state
        update_agent!(CalfAgent) #Apply the update_agent function
    end

# Fn - Carrier State ---------------------------------------------    
    function carrierState!(CalfAgent, calfModel)
    
        # Some calves enter a carrier state
        if (CalfAgent.status == :RR || CalfAgent.status == :RS) && CalfAgent.treatment == :PT
            if rand(calfModel.rng) < calfModel.res_carrier
                CalfAgent.status = :CR
            end
        end

        if CalfAgent.status == :RS
            if rand(calfModel.rng) < calfModel.sens_carrier
                CalfAgent.status = :CS
            end
        end
    end


# Fn - Update Calf Agent ----------------------------------------------    
    function update_agent!(CalfAgent)
        CalfAgent.age += 1*time_resolution # Increment age by 1 day
        
        if CalfAgent.treatment == :T 
            CalfAgent.days_treated += 1*time_resolution
        elseif CalfAgent.treatment == :PT
            CalfAgent.since_tx += 1*time_resolution
        end

        # Add in bacterial data output
        resistant(x) = count(i == :R for i in x)
        sensitive(x) = count(i == :S for i in x)
        adata = [
        (:status, resistant),
        (:status, sensitive)
        ]

        bacterialModel = CalfAgent.submodel

        bacterialModel.properties[:days_treated] = CalfAgent.days_treated
        bacterialModel.properties[:age] = CalfAgent.age

        bactostep, _ = run!(bacterialModel, bact_agent_step!; adata)

        sense = bactostep[:, dataname((:status, sensitive))][2]
        res = bactostep[:, dataname((:status, resistant))][2]

        prop_res = res/(sense + res)

        CalfAgent.bactopop = prop_res

    end


calfSim = initialiseModel()


# Prepare data -------------------------------

infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
infected_resistant(x) = count(i == :IR for i in x)
recoveries_r(x) = count(i == :RR for i in x)
recoveries_s(x) = count(i == :RS for i in x)
treatments(x) = count(i == :T for i in x)
post_treatment(x) = count(i == :PT for i in x)
finished(x) = count(i == :PT for i in x)
carrier_is(x) = count(i == :CS for i in x)
carrier_ir(x) = count(i == :CR for i in x)
status_p(x) = count(i == :P for i in x)

adata = [(:status, infected_sensitive),
 (:status, susceptible),
 (:status, infected_resistant),
 (:status, recoveries_r),
 (:status, recoveries_s),
 (:status, carrier_is),
 (:status, carrier_ir),
 (:treatment, treatments),
 (:treatment, finished),
 (:treatment, post_treatment),
 (:status, status_p)]


# Run the model 
simRun, _ = run!(calfSim, agent_step!, model_step!, 10*time_resolution; adata)


# Export to CSV
CSV.write("./integrated_export.csv", simRun)