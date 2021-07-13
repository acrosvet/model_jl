# Introduction to computational thinking with Julia

#Aim is to create a real world modelling problem
# Combine computer science, maths, epi
# Differential equations models
# The only possible reproducible science is when you have the code
# Only the code

# Julia somehow fosters cooperation

# https://github.com/mitmath/6S083

# Understand the data and build models

# Fit the model to the data

# Julia released 8 years ago
# Now v1.6

# Can be used interactively without compiling. High performance

# Most of julia is written in Julia

# REPL - Read Evaluate Print Loop

sin(3.1)

@edit sin(3.1)

# Code can be more compact and look more like maths

# Can reuse the same code in different ways using multiple dispatch

url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"

url

# Get the URL
typeof(url)


download(url, "covid_data.csv")

# Have a look at the dir contents
readdir()

# Install the CSV package
using Pkg
#Pkg.add("CSV")

using CSV
Pkg.add("DataFrames")
using DataFrames

data = CSV.read("covid_data.csv", DataFrame)

typeof(data)

data = rename(data, 1 => "province", 2=> "country")


# The bang ! operator modifies the variable in place
rename!(data, 1 => "province", 2 => "country")

# Julia is FP not OOP

# Functions can act on different types of objects
Pkg.add("Interact")

# ! is a convention that says the function modifies the argument in place
# the ! creates a new df without modifying the old one
# Or you can overwrite the existing df

# How many cases in US

for i in 1:10
    #println(i)
    @show i #this is a macro
end

typeof(1:10)

collect(1:10) # Collect into an array

@manipulate for i in 1:10
    i
end

countries = data[1:end, 2]

unique_countries = unique(countries)

for i in 1:length(countries)
    @show countries[i]
end

countries[end]

# THis is an array comprension
# Set the index to extract
A_countries = [startswith(country, "A") for country in countries]

# Subset all (:) the data by the defined index
data[A_countries, :]

# This does not work, you need to broadcast the function == to the index of the vector
countries == "Australia"

# using .==

US_rows = findfirst(countries .== "US")

# Subset for the US data rows subsetting everything

US_data_row = data[US_rows, :]

# Make the vriable a vector

US_data = Array(US_data_row[5:end])

using Plots

plot(US_data)

col_names = names(data)

date_strings = String.(names(data))[5:end]

using Dates

format = Dates.DateFormat("m/d/Y")

# Parse dates into another format

parse(Date, date_strings[1], format) + Year(2000)

dates = parse.(Date, date_strings, format) .+ Year(2000)

plot(dates, US_data, xticks = dates[1:5:end], xrotation = 45, leg = :topleft, label = "US data", m=:0)
xlabel!("date")
ylabel!("confirmed cases in the US")
title!("US confirmed COVID-19 cases")



plot(dates, US_data, xticks=dates[1:5:end], xrotation=45, leg=:topleft, 
    label="US data", m=:o,
    yscale=:log10)

xlabel!("date")
ylabel!("confirmed cases in US")
title!("US confirmed COVID-19 cases")



function f(country)
    return country * country
end

f("US")
