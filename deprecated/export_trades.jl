function export_trades!(FarmAgent, farmModel, trade_partner, number_received)
    trade_data = DataFrame(
        step = farmModel.step,
        date = farmModel.date,
        traded_status = FarmAgent.traded,
        sending_farm = FarmAgent.id,
        receiving_farm = trade_partner,
        weight = number_received
    )
    trade_output = open("./export/trades.csv","a")
    CSV.write(trade_output, trade_data, delim = ",", append = true, header = false)
    close(trade_output)
    end