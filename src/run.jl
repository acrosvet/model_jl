
include("./animal_na.jl")

#Initialise a spring model

@time   animalModel = initialiseSpring(
                farmno = Int8(1),
                farm_status = Int8(2),
                system = Int8(1),
                msd = Date(2021,9,24),
                seed = Int8(42),
                optimal_stock = Int16(273),
                optimal_lactating = Int16(273),
                treatment_prob = Float32(0),
                treatment_length = Int8(3),
                carrier_prob = Float32(0.01),
                timestep = Int16(0),
                density_lactating = Int8(5),
                density_dry = Int8(6),
                density_calves = Int8(3),
                date = Date(2021,7,2),
                vacc_rate = Float32(0.5),
                fpt_rate = Float32(0.0),
                prev_r = Float32(0.02),
                prev_p = Float32(0.01),
                prev_cr = Float32(0.1),
                prev_cp = Float32(0.02)
);


#@profview 
@time [animal_step!(animalModel, animalData) for i in 1:1825]

@time export_animalData!(animalData)

write_allData!(allData)