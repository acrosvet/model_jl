function update_msd!(animalModel)

    # Increment msd ---------------------------------------------

    if Year(animalModel.date) > Year(animalModel.msd)
        animalModel.msd += Year(1)
    end

    if animalModel.system == :Split || animalModel.system == :Batch
        if Year(animalModel.date) > Year(animalModel.msd_2)
            animalModel.msd_2 += Year(1)
        end
    end

    if animalModel.system == :Batch
        if Year(animalModel.date) > Year(animalModel.msd_3)
            animalModel.msd_3 += Year(1)
        end

        if Year(animalModel.date) > Year(animalModel.msd_4)
            animalModel.msd_4 += Year(1)
        end
    end

end