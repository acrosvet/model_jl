function stock_numbers!(animalModel)



    animalModel.current_lac = current_stock(:L, animalModel)
    animalModel.current_weaned = current_stock(:W, animalModel)
    animalModel.current_dh = current_stock(:DH, animalModel)
    animalModel.current_heifers = current_stock(:H, animalModel)
    animalModel.current_dry = current_stock(:D, animalModel)
    animalModel.current_calves = current_stock(:C, animalModel)

end