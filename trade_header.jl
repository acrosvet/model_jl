

 trade_header = DataFrame(
    step = 0,
    date = 0,
    sending_farm = 0,
    receiving_farm = 0,
    weight = 0
)

trade_output = open("./export/trades.csv","w")
    CSV.write(trade_output, trade_header, delim = ",", append = true, header = true)
close(trade_output)
