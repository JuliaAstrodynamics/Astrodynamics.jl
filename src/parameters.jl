export Parameter, ParameterArray, getparameters, isparameter, push!, reset!
export lower, upper, initial, value, values, constant
export +, *, -, /, isequal, isless

import Base: +, *, -, /, ==, promote_rule, convert, push!, isequal, isless, values, show

type Parameter
    value::Float64
    initial::Float64
    lower::Float64
    upper::Float64
    variable::Bool
    function Parameter(initial, lower, upper, variable)
        if variable
            if lower == upper
                throw(ArgumentError("Interval must be non-zero."))
            elseif lower > upper
                throw(ArgumentError("The lower bound $lower is higher than the upper bound $upper."))
            elseif initial < lower || initial > upper
                throw(ArgumentError("The inital value $initial is outside the interval [$lower, $upper]."))
            end
        end
        new(initial, initial, lower, upper, variable)
    end
end

show(io::IO, par::Parameter) = par.variable ? print(io, par.lower, " <= ", par.value, " <= ", par.upper) : print(io, par.value)

Parameter(v) = Parameter(v, -Inf, Inf, true)
Parameter(v, lower, upper) = Parameter(v, lower, upper, true)
Parameter(lower, upper) = Parameter((upper-lower)/2, lower, upper, true)
isparameter(par::Parameter) = par.variable
lower(par::Parameter) = par.lower
upper(par::Parameter) = par.upper
initial(par::Parameter) = par.initial
value(par::Parameter) = par.value

function push!(par::Parameter, v)
    par.value = v
    return par
end

function reset!(par::Parameter)
    par.value = par.initial
    return par
end

constant(v) = Parameter(v, v, v, false)
convert{T<:Real}(::Type{Parameter}, v::T) = Parameter(v, v, v, false)
convert(::Type{Float64}, par::Parameter) = par.value
promote_rule(::Type{Parameter}, ::Type{Float64}) = Parameter

typealias ParameterArray Array{Parameter,1}
isparameter(arr::ParameterArray) = Bool[p.variable for p in arr]
values(arr::ParameterArray) = map(value, arr)

getparameters(par::Parameter) = par.variable ? [par] : []
getparameters(arr::ParameterArray) = arr[isparameter(arr)]
function getparameters(arr::AbstractArray)
    params = Parameter[]
    for el in arr
        append!(params, getparameters(el))
    end
    return params
end
function getparameters(val)
    params = Parameter[]
    fields = fieldnames(val)
    if length(fields) != 0
        for field in fields
            append!(params, getparameters(getfield(val, field)))
        end
    end
    return params
end

(+)(lhs::Parameter, rhs::Number) = lhs.value + rhs
(+)(lhs::Number, rhs::Parameter) = lhs + rhs.value
(+)(lhs::Parameter, rhs::AbstractArray) = lhs.value + rhs
(+)(lhs::AbstractArray, rhs::Parameter) = lhs + rhs.value
(-)(lhs::Parameter, rhs::Number) = lhs.value - rhs
(-)(lhs::Number, rhs::Parameter) = lhs - rhs.value
(-)(lhs::Parameter, rhs::AbstractArray) = lhs.value - rhs
(-)(lhs::AbstractArray, rhs::Parameter) = lhs - rhs.value
(*)(lhs::Parameter, rhs::Number) = lhs.value * rhs
(*)(lhs::Number, rhs::Parameter) = lhs * rhs.value
(*)(lhs::Parameter, rhs::AbstractArray) = lhs.value * rhs
(*)(lhs::AbstractArray, rhs::Parameter) = lhs * rhs.value
(/)(lhs::Parameter, rhs::Number) = lhs.value / rhs
(/)(lhs::Number, rhs::Parameter) = lhs / rhs.value
(/)(lhs::Parameter, rhs::AbstractArray) = lhs.value / rhs
(/)(lhs::AbstractArray, rhs::Parameter) = lhs / rhs.value
isequal(x::Number, y::Parameter) = isequal(x, y.value)
isequal(x::Parameter, y::Number) = isequal(x.value, y)
==(x::Number, y::Parameter) = ==(x, y.value)
==(x::Parameter, y::Number) = ==(x.value, y)
isless(x::Parameter, y::Parameter) = isless(x.value, y.value)
isless(x::Number, y::Parameter) = isless(x, y.value)
isless(x::Parameter, y::Number) = isless(x.value, y)
const fun = (
    :abs2, :acos, :acosd, :acosh, :acot, :acotd, :acoth, :acsc, :acscd, :acsch, :airy, :airyai,
    :airyaiprime, :airybi, :airybiprime, :airyprime, :asec, :asecd, :asech, :asin, :asind, :asinh,
    :atan, :atand, :atanh, :besselj0, :besselj1, :bessely0, :bessely1, :cbrt, :cos, :cosd, :cosh,
    :cot, :cotd, :coth, :csc, :cscd, :csch, :digamma, :erf, :erfc, :erfi, :exp, :exp2, :expm1, :gamma,
    :inv, :lgamma, :log, :log10, :log1p, :log2, :sec, :secd, :sech, :sin, :sind, :sinh, :sqrt, :tan,
    :tand, :tanh, :trigamma,
)
for f in fun
    @eval begin
        import Base.$f
        export $f
        $f(par::Parameter) = $f(par.value)
    end
end

(+)(lhs::ParameterArray, rhs::Number) = values(lhs) + rhs
(+)(lhs::Number, rhs::ParameterArray) = lhs + values(rhs)
(-)(lhs::ParameterArray, rhs::Number) = values(lhs) - rhs
(-)(lhs::Number, rhs::ParameterArray) = lhs - values(rhs)
(*)(lhs::ParameterArray, rhs::Number) = values(lhs) * rhs
(*)(lhs::Number, rhs::ParameterArray) = lhs * values(rhs)
(/)(lhs::ParameterArray, rhs::Number) = values(lhs) / rhs
