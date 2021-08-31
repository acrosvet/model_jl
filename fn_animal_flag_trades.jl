"""
flag_trades!(AnimalAgent, animalModel)

* Flag animals eligible to be transferred between farms by the daytrader! function
* Criteria:
    - If stage == :W (weaned calf) && (age ≥10*30 && age ≤ 15*30) 

"""
function flag_trades!(AnimalAgent, animalModel)
    # Set criteria for eligible animals
    # Heifers 
    if AnimalAgent.stage == :H && (AnimalAgent.age ≥ 13*30 && AnimalAgent.age ≤ 18*30)
        AnimalAgent.trade_status = true
    # Dry cows
    elseif AnimalAgent.stage == :D && (AnimalAgent.days_dry ≤ 60)
        AnimalAgent.trade_status = true
    elseif AnimalAgent.stage == :W && (AnimalAgent.age ≥ 60)
        AnimalAgent.trade_status = true
    elseif AnimalAgent.stage == :L && (AnimalAgent.dim ≥ 120)
        AnimalAgent.trade_status = true
    else
        AnimalAgent.trade_status = false
    end

    println(AnimalAgent.trade_status)
end
