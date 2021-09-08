"""
**heat!(AnimalAgent)**\n

* Give empty lactating animals a heat every 21 days

"""
function heat!(AnimalAgent)

if AnimalAgent.pregstat == :E
    if AnimalAgent.dim % 21 == 0
        AnimalAgent.heat = true
    else
        AnimalAgent.heat = false
    end
end

end