function current_stock(lifestage, animalModel)
    stock = [a.stage == lifestage for a in allagents(animalModel)]
    sum(stock)
end