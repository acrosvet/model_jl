#Produce example output for paper:

include("./animal_na.jl");
using Plots

# Spring calving systems ----------------------------------------------------


spring_example = initialiseSpring(
    farmno = Int16(1),
    farm_status = Int16(2),
    system = Int16(1),
    msd = Date(2021,9,24),
    seed = Int16(42),
    optimal_stock = Int16(500),
    optimal_lactating = Int16(500),
    treatment_prob = Float16(0.9),
    treatment_length = Int16(5),
    carrier_prob = Float16(0.1),
    timestep = Int16(0),
    density_lactating = Int16(50),
    density_dry = Int16(250),
    density_calves = Int16(5),
    date = Date(2021,7,2),
    vacc_rate = Float16(0.0),
    fpt_rate = Float16(0.3),
    prev_r = Float16(0.01),
    prev_p = Float16(0.01),
    prev_cr = Float16(0.05),
    prev_cp = Float16(0.05),
    vacc_efficacy = Float16(0.1),
    pen_decon = false
  );
@time [animal_step!(spring_example) for i in 1:2555]


spring_sim = DataFrame(
    timestep = spring_example.sim.timestep,
    pop_r = spring_example.sim.pop_r,
    pop_s = spring_example.sim.pop_s,
    pop_p = spring_example.sim.pop_p,
    pop_d = spring_example.sim.pop_d,
    pop_rec_r = spring_example.sim.pop_rec_r,
    pop_rec_p = spring_example.sim.pop_rec_p,
    pop_car_p = spring_example.sim.pop_car_p,
    pop_car_r  = spring_example.sim.pop_car_r,
    num_calves = spring_example.sim.num_calves,
    num_weaned = spring_example.sim.num_weaned,
    num_dh = spring_example.sim.num_dh,
    num_heifers = spring_example.sim.num_dh,
    num_lactating = spring_example.sim.num_lactating,
    num_dry = spring_example.sim.num_dry,
    pop_er = spring_example.sim.pop_er,
    pop_ep = spring_example.sim.pop_ep,
    inf_calves  = spring_example.sim.inf_calves,
    inf_heifers = spring_example.sim.inf_heifers,
    inf_weaned = spring_example.sim.inf_weaned,
    inf_dh = spring_example.sim.inf_dh,
    inf_dry = spring_example.sim.inf_dry,
    inf_lac = spring_example.sim.inf_lac,
    clinical = spring_example.sim.clinical,
    subclinical = spring_example.sim.subclinical,
    current_b1 = spring_example.sim.current_b1,
    current_b2 = spring_example.sim.current_b2,
    current_b3 = spring_example.sim.current_b3,
    current_b4 = spring_example.sim.current_b4
)
CSV.write("./export/spring_example.csv", spring_sim)

spring_transmissions = DataFrame(
    step = spring_example.transmissions.step,
    from_id = spring_example.transmissions.from_id,
    to_id = spring_example.transmissions.to_id,
    stage = spring_example.transmissions.stage,
    from = spring_example.transmissions.from,
    to = spring_example.transmissions.to,
    type = spring_example.transmissions.type
)


CSV.write("./export/spring_transmissions.csv", spring_transmissions)


spring_infections = DataFrame(
    id = spring_example.infections.id,
    status = spring_example.infections.status,
    step = spring_example.infections.step,
    stage = spring_example.infections.stage,
    clin = spring_example.infections.clin,
    death = spring_example.infections.death,
    days_inf = spring_example.infections.days_inf,
    days_exposed = spring_example.infections.days_exposed,
    vaccinated = spring_example.infections.vaccinated,
    fpt = spring_example.infections.fpt,
    age = spring_example.infections.age
)

CSV.write("./export/spring_infections.csv", spring_infections)

# Split calving systems ----------------------------------------------------


    split_example = initialiseSplit(
        farmno = Int16(1),
        farm_status = Int16(2),
        system = Int16(2),
        msd = Date(2021,9,24),
        seed = Int16(42),
        optimal_stock = Int16(500),
        optimal_lactating = Int16(500),
        treatment_prob = Float16(0.9),
        treatment_length = Int16(5),
        carrier_prob = Float16(0.1),
        timestep = Int16(0),
        density_lactating = Int16(50),
        density_dry = Int16(250),
        density_calves = Int16(5),
        date = Date(2021,7,2),
        vacc_rate = Float16(0.0),
        fpt_rate = Float16(0.3),
        prev_r = Float16(0.01),
        prev_p = Float16(0.01),
        prev_cr = Float16(0.05),
        prev_cp = Float16(0.05),
        vacc_efficacy = Float16(0.1),
        pen_decon = false
    );
    @time [animal_step!(split_example) for i in 1:2555]



    split_sim = DataFrame(
        timestep = split_example.sim.timestep,
        pop_r = split_example.sim.pop_r,
        pop_s = split_example.sim.pop_s,
        pop_p = split_example.sim.pop_p,
        pop_d = split_example.sim.pop_d,
        pop_rec_r = split_example.sim.pop_rec_r,
        pop_rec_p = split_example.sim.pop_rec_p,
        pop_car_p = split_example.sim.pop_car_p,
        pop_car_r  = split_example.sim.pop_car_r,
        num_calves = split_example.sim.num_calves,
        num_weaned = split_example.sim.num_weaned,
        num_dh = split_example.sim.num_dh,
        num_heifers = split_example.sim.num_dh,
        num_lactating = split_example.sim.num_lactating,
        num_dry = split_example.sim.num_dry,
        pop_er = split_example.sim.pop_er,
        pop_ep = split_example.sim.pop_ep,
        inf_calves  = split_example.sim.inf_calves,
        inf_heifers = split_example.sim.inf_heifers,
        inf_weaned = split_example.sim.inf_weaned,
        inf_dh = split_example.sim.inf_dh,
        inf_dry = split_example.sim.inf_dry,
        inf_lac = split_example.sim.inf_lac,
        clinical = split_example.sim.clinical,
        subclinical = split_example.sim.subclinical,
        current_b1 = split_example.sim.current_b1,
        current_b2 = split_example.sim.current_b2,
        current_b3 = split_example.sim.current_b3,
        current_b4 = split_example.sim.current_b4
    )
    CSV.write("./export/split_example.csv", split_sim)
    
    split_transmissions = DataFrame(
        step = split_example.transmissions.step,
        from_id = split_example.transmissions.from_id,
        to_id = split_example.transmissions.to_id,
        stage = split_example.transmissions.stage,
        from = split_example.transmissions.from,
        to = split_example.transmissions.to,
        type = split_example.transmissions.type
    )
    
    CSV.write("./export/split_transmissions.csv", split_transmissions)



split_infections = DataFrame(
    id = split_example.infections.id,
    status = split_example.infections.status,
    step = split_example.infections.step,
    stage = split_example.infections.stage,
    clin = split_example.infections.clin,
    death = split_example.infections.death,
    days_inf = split_example.infections.days_inf,
    days_exposed = split_example.infections.days_exposed,
    vaccinated = split_example.infections.vaccinated,
    fpt = split_example.infections.fpt,
    age = split_example.infections.age
)

CSV.write("./export/split_infections.csv", split_infections)
# Spring calving systems ----------------------------------------------------

batch_example = initialiseBatch(
    farmno = Int16(1),
    farm_status = Int16(2),
    system = Int16(3),
    msd = Date(2021,9,24),
    seed = Int16(42),
    optimal_stock = Int16(500),
    optimal_lactating = Int16(500),
    treatment_prob = Float16(0.9),
    treatment_length = Int16(5),
    carrier_prob = Float16(0.1),
    timestep = Int16(0),
    density_lactating = Int16(50),
    density_dry = Int16(250),
    density_calves = Int16(5),
    date = Date(2021,7,2),
    vacc_rate = Float16(0.0),
    fpt_rate = Float16(0.3),
    prev_r = Float16(0.01),
    prev_p = Float16(0.01),
    prev_cr = Float16(0.05),
    prev_cp = Float16(0.05),
    vacc_efficacy = Float16(0.1),
    pen_decon = false
  );
@time [animal_step!(batch_example) for i in 1:2555]



batch_sim = DataFrame(
    timestep = batch_example.sim.timestep,
    pop_r = batch_example.sim.pop_r,
    pop_s = batch_example.sim.pop_s,
    pop_p = batch_example.sim.pop_p,
    pop_d = batch_example.sim.pop_d,
    pop_rec_r = batch_example.sim.pop_rec_r,
    pop_rec_p = batch_example.sim.pop_rec_p,
    pop_car_p = batch_example.sim.pop_car_p,
    pop_car_r  = batch_example.sim.pop_car_r,
    num_calves = batch_example.sim.num_calves,
    num_weaned = batch_example.sim.num_weaned,
    num_dh = batch_example.sim.num_dh,
    num_heifers = batch_example.sim.num_dh,
    num_lactating = batch_example.sim.num_lactating,
    num_dry = batch_example.sim.num_dry,
    pop_er = batch_example.sim.pop_er,
    pop_ep = batch_example.sim.pop_ep,
    inf_calves  = batch_example.sim.inf_calves,
    inf_heifers = batch_example.sim.inf_heifers,
    inf_weaned = batch_example.sim.inf_weaned,
    inf_dh = batch_example.sim.inf_dh,
    inf_dry = batch_example.sim.inf_dry,
    inf_lac = batch_example.sim.inf_lac,
    clinical = batch_example.sim.clinical,
    subclinical = batch_example.sim.subclinical,
    current_b1 = batch_example.sim.current_b1,
    current_b2 = batch_example.sim.current_b2,
    current_b3 = batch_example.sim.current_b3,
    current_b4 = batch_example.sim.current_b4
)
CSV.write("./export/batch_example.csv", batch_sim)

batch_transmissions = DataFrame(
    step = batch_example.transmissions.step,
    from_id = batch_example.transmissions.from_id,
    to_id = batch_example.transmissions.to_id,
    stage = batch_example.transmissions.stage,
    from = batch_example.transmissions.from,
    to = batch_example.transmissions.to,
    type = batch_example.transmissions.type
)

CSV.write("./export/batch_transmissions.csv", batch_transmissions)


batch_infections = DataFrame(
    id = batch_example.infections.id,
    status = batch_example.infections.status,
    step = batch_example.infections.step,
    stage = batch_example.infections.stage,
    clin = batch_example.infections.clin,
    death = batch_example.infections.death,
    days_inf = batch_example.infections.days_inf,
    days_exposed = batch_example.infections.days_exposed,
    vaccinated = batch_example.infections.vaccinated,
    fpt = batch_example.infections.fpt,
    age = batch_example.infections.age
)

CSV.write("./export/batch_infections.csv", batch_infections)