function update_psc!(animalModel)

    # Increment psc ---------------------------------------------------
if animalModel.system != :Continuous
    if Year(animalModel.date) > Year(animalModel.psc)
        animalModel.psc += Year(1)
    end

if animalModel.system == :Split || animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.psc_2)
        animalModel.psc_2 += Year(1)
    end
end

if animalModel.system == :Batch
    if Year(animalModel.date) > Year(animalModel.psc_3)
        animalModel.psc_3 += Year(1)
    end

    if Year(animalModel.date) > Year(animalModel.psc_4)
        animalModel.psc_4 += Year(1)
    end
end


end
end