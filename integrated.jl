using Agents
using Random
using DrWatson
using CSV
using InteractiveDynamics #Plot and animate ABMs
using CairoMakie #Backend for video creation


# Def - BacterialAgent --------------------------------

    mutable struct BacterialAgent <: AbstractAgent
        id::Int64
        pos::NTuple{2, Int}
        status::Symbol
        strain::Int64
    end

# ABM - Bacteria ---------------------------------------
    include("gridsub.jl")

# Def - AnimalAgent --------------------
    mutable struct AnimalAgent <: AbstractAgent
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
        stage::Symbol
    end

# Def - time resolution ------------


    const time_resolution = 1
    
# ABM - Animal  --------------------

  
    #Define model initialisation functions. 

    function initialiseModel(
        N = 100, #Default number of animals
        seed = 42, #Random seed
        animalProximityRadius = 0.5, #Radius for effective contact
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
        stage = :C,
        num_calves = N*0.2,
        num_weaned = N*0.2,
        num_heifers = N*0.2,
        num_lac = N*0.4,
    )
    #End header
    #Body

    #Define the agent space. At present, avoid observing pen boundaries.
    agentSpace = ContinuousSpace((10,10), 1; periodic = true) #Relatinship to real space?
    #Specify the disease dynamics  as a Dictionary to be passed to the model
    pathogenProperties = @dict(
        animalProximityRadius,
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
        submodel,
        stage)# Dictionary of disease properties

    # Define the model: Agent type, agent space, properties, and type of random seed
    animalModel = ABM(AnimalAgent, agentSpace, properties = pathogenProperties, rng = MersenneTwister(seed))
    
    # Set the initial age of the animals
    function initial_age(n)
        if n <= num_calves
            rand(1:60)
        elseif n > (num_calves + 1) && n <= (num_calves + num_weaned)
            rand(61:(30*13))
        elseif n > (num_calves + num_weaned + 1 ) && n <= (num_calves + num_weaned + num_heifers)
            rand((13*30):(24*30))
        else n > (num_calves + num_weaned + num_heifers + 1) && n <= (num_calves + num_weaned + num_heifers + num_lac)
            rand((24*30):(6*365))
        end
    end

    # Set the initial lifestage 

    function initial_stage(age)
        if age < 60
            :C
        elseif age ≥ 60 && age ≤ 13*30
            :W
        elseif age > 13*30 && age ≤ 24*30
            :H
        elseif age > 24*30 
            :L
        end
    end

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
            sincos(2π*rand(animalModel.rng)) .*movement
        elseif status == :IS
            sincos(2π*rand(animalModel.rng)) .*(movement/2)
        elseif status == :IR
            sincos(2π*rand(animalModel.rng)) .*(movement/2.5)
        elseif status == :M
            (0.0,0.0)
        end
    end


    #Define the initial state of the system. Attributes for each animal in the system.
    for n in 1:N
        # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
        pos = Tuple(10*rand(animalModel.rng, 2))
        status = initial_status(n, init_ir, init_is)
        age = initial_age(n)
        βᵣ = βᵣ
        βₛ = βₛ
        treatment = treatment
        treatment_prob = treatment_prob
        days_treated = days_treated
        treatment_duration = treatment_duration
        bactopop = 0.0
        submodel = submodel
        vel = initial_velocity(status, movement)
        stage = initial_stage(age)
        add_agent!(pos, animalModel, vel, age, status, βᵣ, βₛ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage)
    end

        return animalModel
    end



    animalModel = initialiseModel()
# Utility functions -------------

# Fn - Transmit resistant (Animal) ------------------------
    function transmit_resistant!(a1,a2)
        count(a.status == :IR for a in (a1, a2)) ≠ 1 && return
            infected, healthy = a1.status == :IR ? (a1, a2) : (a2, a1)
    #If a random number is below the transmssion parameter, infect, provided that the contacted animal is susceptible.
            if (rand(animalModel.rng) < infected.βᵣ*infected.bactopop) && healthy.status == :S
                healthy.status = :ER
            else
                healthy.status = healthy.status
            end

    end

# Fn - Transmit sensitive (Animal) -----------------------    
    function transmit_sensitive!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(animalModel.rng) < infected.βₛ*(1-infected.bactopop)) && healthy.status == :S
            healthy.status = :IS
            # Else we set the status of the healthy animal to IS
        else
            healthy.status = healthy.status
        end
    end

# Fn - Transmit carrier (Animal) ----------------------------    
    function transmit_carrier!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
            if healthy.treatment == :PT && (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ)
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

# Fn - Transmit carrier (Animal) ---------------------------------------    
    function transmit_carrier_is!(a1,a2)
        # Both calves cannot be infected, if they are, return from the function. It also can't be 0
        count(a.status == :CS for a in (a1, a2)) ≠ 1 && return
        # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
        infected, healthy = a1.status == :CS ? (a1, a2) : (a2, a1)

        #IF a random number is greater than βₛ, then we return out of the function
        
        if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βₛ) && (healthy.status == :S || healthy.status == :RS)
            if healthy.treatment == :PT && (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ)
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
        
        if (rand(animalModel.rng) < rand(animalModel.rng)*infected.βᵣ) && (healthy.status == :S || healthy.status == :RS || healthy.status == :RR)
                healthy.status = :ER
                healthy.inf_days_ir = 0
            # Else we set the status of the healthy animal to its existing status
        else
            healthy.status = healthy.status
        end
    end

# Fn - Treatment effect (Animal) -------------------------    
    function treatment_effect!(AnimalAgent)
    # During treatment, sensitive calves become less contagious
    if AnimalAgent.treatment == :T && AnimalAgent.status == :IS
        AnimalAgent.βₛ = 0.8(AnimalAgent.βₛ)
    # Resistant calves remain unchanged
    elseif AnimalAgent.treatment == :T && AnimalAgent.status == :IR
        AnimalAgent.βᵣ = AnimalAgent.βᵣ
    end

    end

# Fn - Bacterial dynamics --------------------

    function bacto_dyno!(AnimalAgent)
        if AnimalAgent.bactopop > 0.5 && AnimalAgent.status == :ER
            AnimalAgent.status = :IR
        else return
        end

    end

# Fn - End of treatment ---------------------------    
function endTreatment!(AnimalAgent, animalModel)
    #Define the endpoint of treatment
            if AnimalAgent.treatment != :T && return
            elseif AnimalAgent.days_treated ≥ animalModel.treatment_duration
                AnimalAgent.treatment = :PT
            end
    end

# Fn - start of treatment -------------------------    

function treatment!(AnimalAgent, animalModel)
        # Assign a treatment status
        if (AnimalAgent.status != :IS && AnimalAgent.status != :IR) && return
        elseif AnimalAgent.treatment == :U && (rand(animalModel.rng) < animalModel.treatment_prob)
            AnimalAgent.treatment = :T
            
        end
    
    end

# Fn - Recovery ------------------------------------------------------    

    function recover!(AnimalAgent, animalModel)
        if (AnimalAgent.inf_days_is ≥ 5*time_resolution && AnimalAgent.status == :IS) && (rand(animalModel.rng) < animalModel.sponrec_is)
            AnimalAgent.status = :RS
        elseif AnimalAgent.inf_days_ir ≥ 5*time_resolution && AnimalAgent.status == :IR && (rand(animalModel.rng) < animalModel.sponrec_ir)
            AnimalAgent.status = :RR
        end
    end

# Fn - retreatment ----------------------------------------------------------

    function retreatment!(AnimalAgent, animalModel)
        # Assign a treatment status
        if (AnimalAgent.status == :IS || AnimalAgent.status == :IR)
            if AnimalAgent.treatment == :PT && (rand(animalModel.rng) < animalModel.treatment_prob)
                AnimalAgent.treatment == :RT 
            else
                AnimalAgent.treatment = AnimalAgent.treatment
            end
        end

    end

# Fn - Mortality ------------------------------------------------------------    
    function mortality!(AnimalAgent, animalModel)
        if AnimalAgent.status == :IS && (rand(animalModel.rng) < animalModel.mortalityRateSens)
        kill_agent!(AnimalAgent, animalModel)
        else 
        AnimalAgent.inf_days_is += 1*time_resolution
        end
    
        if AnimalAgent.status == :IR && (rand(animalModel.rng) < animalModel.mortalityRateRes)
            kill_agent!(AnimalAgent, animalModel)
        else
            AnimalAgent.inf_days_ir += 1*time_resolution
        end
    
    end

# Fn - Bact (agent step) ----------------------------------

    function bact_agent_step!(BacterialAgent, bacterialModel)
            #fitness!(BacterialAgent, bacterialModel)
            bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
            bact_plasmid_transfer!(BacterialAgent, bacterialModel)
            bact_treatment_response!(BacterialAgent, bacterialModel)

    end

# Fn - Animal Model Step -------------------------------------

    function model_step!(animalModel)
        #Define the proximity for which infection may occur
        r = animalModel.animalProximityRadius
        for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
            elastic_collision!(a1, a2) #Collison dynamics for each animal
            transmit_sensitive!(a1,a2) #Sensitive transmission function
            transmit_resistant!(a1,a2) #Resistant transmission function
            transmit_carrier_is!(a1,a2)
            transmit_carrier_ir!(a1,a2)
            
        end
    end

# Fn - Animal Agent Step -----------------------------------------------------------    

    function agent_step!(AnimalAgent, animalModel)
        #resist!(AnimalAgent)
        bacto_dyno!(AnimalAgent)
        move_agent!(AnimalAgent, animalModel, animalModel.timestep) #Move the agent in space
        treatment!(AnimalAgent, animalModel) #Introduce treatment
        treatment_effect!(AnimalAgent) #Effect of treatment on transmission.
        endTreatment!(AnimalAgent, animalModel)
        retreatment!(AnimalAgent, animalModel) #Effect of retreatment
        mortality!(AnimalAgent, animalModel) #Introduce mortality
        recover!(AnimalAgent, animalModel) # Introduce recovery
        carrierState!(AnimalAgent, animalModel) #Introduce a carrier state
        update_agent!(AnimalAgent) #Apply the update_agent function
    end

# Fn - Carrier State ---------------------------------------------    
    function carrierState!(AnimalAgent, animalModel)
    
        # Some calves enter a carrier state
        if (AnimalAgent.status == :RR || AnimalAgent.status == :RS) && AnimalAgent.treatment == :PT
            if rand(animalModel.rng) < animalModel.res_carrier
                AnimalAgent.status = :CR
            end
        end

        if AnimalAgent.status == :RS
            if rand(animalModel.rng) < animalModel.sens_carrier
                AnimalAgent.status = :CS
            end
        end
    end


# Fn - Update Animal Agent ----------------------------------------------    
    function update_agent!(AnimalAgent)
        AnimalAgent.age += 1 # Increment age by 1 day
        
        if AnimalAgent.treatment == :T 
            AnimalAgent.days_treated += 1
        elseif AnimalAgent.treatment == :PT
            AnimalAgent.since_tx += 1
        end

        if AnimalAgent.age < 60
            AnimalAgent.stage = :C
        elseif AnimalAgent.age ≥ 60 && AnimalAgent.age ≤ 13*30
            AnimalAgent.stage = :W
        elseif AnimalAgent.age > 13*30 && AnimalAgent.age ≤ 24*30
            AnimalAgent.stage = :H
        elseif AnimalAgent.age > 24*30 
            AnimalAgent.stage = :L
        end

        # Add in bacterial data output
        resistant(x) = count(i == :R for i in x)
        sensitive(x) = count(i == :IS for i in x)
        susceptible(x) = count(i == :S for i in x)
        adata = [
        (:status, resistant),
        (:status, sensitive),
        (:status, susceptible)
        ]

        bacterialModel = AnimalAgent.submodel
        bacterialModel.properties[:total_status] = AnimalAgent.status
        bacterialModel.properties[:days_treated] = AnimalAgent.days_treated
        bacterialModel.properties[:age] = AnimalAgent.age

        bactostep, _ = run!(bacterialModel, bact_agent_step!; adata)

        sense = bactostep[:, dataname((:status, sensitive))][2]
        res = bactostep[:, dataname((:status, resistant))][2]
        sus = bactostep[:, dataname((:status, susceptible))][2]
        prop_res = res/(sense + res)

        AnimalAgent.bactopop = prop_res

    end


animalSim = initialiseModel()


# Prepare data -------------------------------

stage_c(x) = count(i == :C for i in x)
stage_w(x) = count(i == :W for i in x)
stage_h(x) = count(i == :H for i in x)
stage_l(x) = count(i == :L for i in x)

adata = [
    (:stage, stage_c)
    (:stage, stage_w)
    (:stage, stage_h)
    (:stage, stage_l)
]

#= infected_sensitive(x) = count(i == :IS for i in x)
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
stage(x) = count(i == :W for i in x)
 =#
#= adata = [(:status, infected_sensitive),
 (:status, susceptible),
 (:status, infected_resistant),
 (:status, recoveries_r),
 (:status, recoveries_s),
 (:status, carrier_is),
 (:status, carrier_ir),
 (:treatment, treatments),
 (:treatment, finished),
 (:treatment, post_treatment),
 (:stage, stage)]
 =#

# Run the model 
simRun, _ = run!(animalSim, agent_step!, model_step!, 1*time_resolution; adata)


# Export to CSV
CSV.write("./integrated_export.csv", simRun)

#= figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Number of calves")
l1 = lines!(ax, simRun[:, dataname((:status, infected_sensitive))], color = :orange)
l2 = lines!(ax, simRun[:, dataname((:status, susceptible))], color = :green)
l3 = lines!(ax, simRun[:, dataname((:status, infected_resistant))], color = :red)
l4 = lines!(ax, simRun[:, dataname((:status, recoveries_r))], color = :black)
l5 = lines!(ax, simRun[:, dataname((:status, recoveries_s))], color = :grey)


figure  =#