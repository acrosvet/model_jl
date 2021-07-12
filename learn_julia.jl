using Base: Float64
# Multiple dispatch

# many functions with the same name that take different arguments
# Uses functions and types to determine the correct method

# Calling methodson +

methods(+)

# @ which sees which method will be used

@which 3+3

@which 3.0 + 3.0

@which 3 + 3.0

# We can extend methods my creating new methods or it

import Base: +

# Say we want to concatenate strings with it

"Hello" + "World"

@which "Hello" + "World"

+(x::String, y::String) = string(x,y)

"hello" + "world"

# Nice, can assign methods having dispatched on the types of input arguuments

foo(x,y) = println("duck-typed foo!")
foo(x::Int, y::Float64) = println("foo is an integer and a float")
foo(x::Float64, y::Float64) = println("foo with two floats")
foo(x::Int, y::Int) = println("foo witht wo integers")

# It then looks for the type and assigns the version of foo accordingly

foo(1,1)
foo(1.1, 1.1)
foo(1, 1.0)
# When we call on true  and false if we didn't specify boolean values, will use the fallback method
foo(true, false)

# Julia is fast!

# Benchmark the sum function

# Declare a very large vector, with 10 000 000 elements
a = rand(10^7)

sum(a)
using Pkg
Pkg.add("BenchmarkTools")

using(BenchmarkTools)

# Gives a reliable measure of performance

# Declare some C

C_code = """

#include <stddef.h>
double c_sum(size_t n double *X){
    double s = 0.0;
    for (size_t i =0; i < n; ++i){
        s += X[i];
    }
    return s;
}
"""

# Basic linear algebra

A = rand(1:4, 3,3)

B = A

C = copy(A)

[B C]

A[1] = 17

[B C]

# Does noes not change the matrix x
# When we assign, we are not creating a new matrix
# Both B and A refer to the same place in memory
# Copy creates a new object
# When we update A we also update C

x = ones(3)

b = A*x

# Store the output in B

# Conjugte transposition by tacking on an apostrophe

Asym = A + A'

# Just transposition

# You don't need the * operator in Julia

Apd = A'A

# Backslash allows a linear system to be solved

A\b

# When there is not a unique solution

Atall = A[:,1:2]
display(Atall)

# Factorisations

