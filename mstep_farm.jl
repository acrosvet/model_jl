function farm_mstep!(farmModel)
    
for a in allagents(farmModel)
    a.traded = false
end

farmModel.date += Day(1)
farmModel.step += 1



end