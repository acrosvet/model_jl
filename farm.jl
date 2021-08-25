using Agents
using SimpleWeightedGraphs: SimpleWeightedDiGraph # will make social network
using SparseArrays: findnz                        # for social network connections
using Random: MersenneTwister  
using LightGraphs
using DrWatson
using Distributions

time_resolution = 1

include("agent_types.jl")
include("abm_animal.jl")
include("gridsub.jl")

#= 
include("abm_animal.jl")
# Utility functions -------------

# Animal transmission functions -------

include("fns_animal_transmission.jl")

# Animal treatment -------------

include("fns_animal_treatment.jl")

# Bacterial dynamics --------------

include("fn_bacteria_dynamics.jl")

# Animal recovery -----------------

include("fn_animal_recovery.jl")

# Fn - Mortality ------------------------------------------------------------    

include("fn_animal_mortality.jl")

# Fn - Bact (agent step) ----------------------------------

include("astep_bacteria.jl")

# Fn - Animal Model Step -------------------------------------

include("mstep_animal.jl")

# Fn - Add new calves -------------------------------------------------------------
include("fn_animal_birth.jl")

# Fn - Animal Agent Step -----------------------------------------------------------    
include("astep_animal.jl")

# Fn - Carrier State ---------------------------------------------    
include("fn_animal_carrier.jl")

# Fn - Update Animal Agent ----------------------------------------------    
include("fn_animal_update.jl")
 =#
mutable struct FarmAgent <: AbstractAgent
    id::Int
    pos::Int
    status::Symbol #Infection status
    tradelevel::Int #Trading relationships
    trades_from::Int
    trades_to::Int
    ncows::Int #Number of animals
    system::Symbol #Calving system
    animalModel::AgentBasedModel
end

function initialiseFarms(
    numfarms = 2,
    seed = 42,
    calday = rand(1:365),
    tradelevel = 2,
    timestep = 1
)


FarmProperties = @dict(
    numfarms,
    seed,
    rng = MersenneTwister(seed),
    contacts = 0,
    calday,
    tradelevel,
    timestep,
)


agentSpace = GraphSpace(complete_digraph(numfarms))

farmModel = ABM(FarmAgent, agentSpace, properties = FarmProperties)

id = 0

for farm in 1:numfarms
    id +=1
    status = farm % 2 == 0 ? :S : :I
    tradelevel = rand(1:5)
    ncows = rand(100:150)
    system = :Spring
    trades_from = 0
    trades_to = 0
    animalModel = initialiseModel(ncows)
    #submodel = submodel
    add_agent!(id, farmModel, status, tradelevel, trades_from, trades_to, ncows, system, animalModel)
    
end

    return farmModel
end

farmModel = initialiseFarms()

function contact!(FarmAgent, farmModel)
    
    #submodel = agent.submodel

    trade_partners = node_neighbors(FarmAgent, farmModel)

    trade_partner = rand(1:length(trade_partners))
end



function farm_update_agent!(FarmAgent, farmModel)

function birth!(animalModel)

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

    if (animalModel.calday ≥ 182 && animalModel.calday ≤ 272) && (rand(animalModel.rng) < 0.5)


            # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
            pos = Tuple(10*rand(animalModel.rng, 2))
            age = 0
            status = :S
            βᵣ = animalModel.βᵣ
            βₛ = animalModel.βₛ
            days_treated = 0
            inf_days_is = 0
            inf_days_ir = 0
            treatment = :U
            bactopop = 0.0
            since_tx = 0
            submodel = initialisePopulation()
            vel = initial_velocity(status, animalModel.movement)
            stage = :C
            dim = 0
            days_dry = 0
            add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry)    
        end

end

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

    # Cull agent -------------------------------

    if AnimalAgent.stage == :L && (0.3/365 > rand(animalModel.rng))
        kill_agent!(AnimalAgent, animalModel)
    else
        return
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
function update_agent!(AnimalAgent)
    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Change stage over time ------------------------
    if AnimalAgent.age < 60
        AnimalAgent.stage = :C
    elseif AnimalAgent.age ≥ 60 && AnimalAgent.age ≤ 13*30
        AnimalAgent.stage = :W
    elseif AnimalAgent.age > 13*30 && AnimalAgent.age ≤ 24*30
        AnimalAgent.stage = :H
    elseif AnimalAgent.age > 24*30 && AnimalAgent.stage != :D
        AnimalAgent.stage = :L 
    elseif AnimalAgent.stage == :D && AnimalAgent.days_dry > rand(60:90)
        AnimalAgent.dim = 0
        AnimalAgent.days_dry = 0
    end

    #Increase dim --------------------

    if AnimalAgent.stage == :L 
        AnimalAgent.dim += 1
    else
        AnimalAgent.dim = AnimalAgent.dim
    end

    # Dryoff -------------------

    if AnimalAgent.stage == :L && AnimalAgent.dim > (rand(305:400))
        AnimalAgent.stage = :D
        AnimalAgent.days_dry += 1
    else
        AnimalAgent.stage = AnimalAgent.stage
    end

    if AnimalAgent.stage == :D
        AnimalAgent.days_dry += 1
    else
        return
    end

    # Calve ----------------------

    if AnimalAgent.stage == :D && AnimalAgent.days_dry > (rand(60:90))
        AnimalAgent.stage = :L
        AnimalAgent.dim = 0
    else
        return
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

    sense = bactostep[:,:sensitive_status][2]
    res = bactostep[:,:resistant_status][2]
    sus = bactostep[:,:susceptible_status][2]
    prop_res = res/(sense + res)

    AnimalAgent.bactopop = prop_res

end
# Fn - Bacterial dynamics --------------------

function bacto_dyno!(AnimalAgent)
    if AnimalAgent.bactopop > 0.5 && AnimalAgent.status == :ER
        AnimalAgent.status = :IR
    else return
    end

end


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
function transmit_sensitive!(a1,a2, animalModel)
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

    function animal_model_step!(animalModel)
        #Define the proximity for which infection may occur
        birth!(animalModel)
        r = animalModel.animalProximityRadius
        for (a1,a2) in interacting_pairs(animalModel, r, :nearest)
            elastic_collision!(a1, a2) #Collison dynamics for each animal
            transmit_sensitive!(a1,a2) #Sensitive transmission function
            transmit_resistant!(a1,a2) #Resistant transmission function
            transmit_carrier_is!(a1,a2)
            transmit_carrier_ir!(a1,a2)
            
        end
    
    
        if animalModel.calday > 365
            animalModel.calday = 0
        else
            animalModel.calday = animalModel.calday
        end
    
        animalModel.calday += 1
    
        
    end
    
    function animal_agent_step!(AnimalAgent, animalModel)
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


    susceptible(x) = count(i == :S for i in x)

    adata = [
    (:status, susceptible) 
    ]

    animalModel = FarmAgent.animalModel


    animals, _ = run!(animalModel, animal_agent_step!, animal_model_step!, 1; adata)
    
    has_stage(AnimalAgent, status) = AnimalAgent.status == status

    is_traded(status) = AnimalAgent -> has_stage(AnimalAgent, status) 
    
    traded_agent = random_agent(animalModel, is_traded(:IS))
    

    println(traded_agent.bactopop)

 #
    #println(stage_c)
#= 
    if model[trade_partner].status == :S && agent.status == :I
       model[trade_partner].status = :I
    else
        return
    end
 =#
 


end

function farm_agent_step!(FarmAgent, farmModel)
    contact!(FarmAgent, farmModel)
    farm_update_agent!(FarmAgent, farmModel)
    #transmit!(agent, model)
end

infected(x) = count(i == :I for i in x)
recovered(x) = count(i == :S for i in x)

adata = [
    (:status, infected)
    (:status, recovered)
]

data, _ = run!(farmModel, farm_agent_step!, 5; adata)