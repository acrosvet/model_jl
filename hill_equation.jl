# Define a model for the growth rate of bacteria in an individual calf.
# After Graesboll et al (2014)

# α_max = maximum growth rate of the bacteria in the absence of antibiotics in bacterial strain i
# cᵞ the anitmicrobial concentraton in calf j
# EC50ᵞ  = Rate of antibiotic concentration at which bacterial growth is halved
# γᵢ is the 'Hill Coefficient', determining the steepness of the curve around EC50

"""
function bac_growth
Model the growth rate of bacteria strain i in animal j using a Hill type equation
* α_max = maximum growth rate of the bacteria in the absence of antibiotics in bacterial strain i
* cᵞ the anitmicrobial concentraton in calf j
* EC50ᵞ  = Rate of antibiotic concentration at which bacterial growth is halved
* γᵢ is the 'Hill Coefficient', determining the steepness of the curve around EC50
"""
function bac_growth(α_max, γ, c, EC50)
    α_max*(1 - c^γ/(EC50^γ + c^γ))

end

"""
function competitive growth

Model the competitive growth of multiple bacterial strains in a single animal

S: The bacterial count in the infected animal
H: The anitmicrobial concentraiton given by the function bac_growth
C: The maximum intestinal carrying capacity
"""

function comp_growth(S,H,C)
end


"""