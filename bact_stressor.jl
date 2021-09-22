function stress!(bacterialModel)
    if bacterialModel.stress == true && bacterialModel.total_status == :CS
        bacterialModel.total_status == :ES
        bacterialModel.carrier = :yes
    elseif bacterialModel.stress == true && bacterialModel.total_status == :CR
        bacterialModel.total_status == :ER 
        bacterialModel.carrier = :yes
    end
end