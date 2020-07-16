@def title = "Why I use Julia"
@def author = "Josh Day"

# Why I Use Julia


## Multiple Dispatch + JIT (Dynamic and Compiled)

When I am asked why I use Julia, my immediate response is “multiple dispatch”. Julia is well-known for performance, but that is only a part of what keeps me using it every day. [Multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch)  is a feature where different code is called by a function depending on the types of the arguments. Combined with the JIT (Just-in-time compiler), Julia will automatically compile specialized code for each set of argument types the function is called with.

### Simple Example

```
f(x) = x + x
```

I have not given Julia any hint as to what the type of the argument is, but as long as it’s a type that supports addition, Julia will compile an optimized method for it. You can peek at the LLVM compiler code with the `@code_llvm` macro.  

```
julia> @code_llvm f(1)

define i64 @julia_f_62945(i64) #0 !dbg !5 {
top:
  %1 = shl i64 %0, 1
  ret i64 %1
}

julia> @code_llvm f(1.0)

define double @julia_f_62949(double) #0 !dbg !5 {
top:
  %1 = fadd double %0, %0
  ret double %1
}
```

Ignoring some of the details, notice that these functions do not call the same code: one method is specific to 64-bit integers and the other for double precision floats!

### What About More Complicated Types?

Here we will use the [Distributions](https://github.com/JuliaStats/Distributions.jl)  package to implement a naive quantile finder using [Newton's Method](https://en.wikipedia.org/wiki/Newton%27s_method):

$$
x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}
$$

For quantiles, we are trying to find the number `x`, for a given number `q` (between 0 and 1), such that

```julia
cdf(dist, x) - q = 0
```

where `cdf` is the [cumulative distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function) for distribution `dist`. We also need the derivative of the cdf, which is the [probability density function](https://en.wikipedia.org/wiki/Probability_density_function), or pdf.

```
using Distributions

function myquantile(d, q)
    out = mean(d)
    for i in 1:10
        out -= (cdf(d, out) - q) / pdf(d, out)
    end
    out
end
```

Again, I have not told Julia anything about what `d` or `q` is, but when I provide arguments such as `Distributions.Normal(0, 1)` and `0.5`, Julia will compile specialized code to run the algorithm and then return the median for a standard normal distribution (which is 0).

```
julia> myquantile(Normal(0,1), .5)
0.0
```

Right out of the box, `myquantile` will also work with other distributions!  In fact, as long as the function arguments have methods for `mean`, `cdf`, and `pdf`, it will just work! If you were to implement this quantile algorithm in R, you would need to rewrite it for each distribution using the [`dnorm`/`pnorm`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/Normal.html)  family of functions.

```
julia> myquantile(Gamma(5,1), .7)
5.890361313697006

julia> myquantile(Beta(2, 4), .1)
0.11223495854585855
```

## Takeaway

The language you use has a tremendous effect on how you approach problems (see [linguistic relativity](https://en.wikipedia.org/wiki/Linguistic_relativity)). I have a background in statistics, so naturally R was one of the first languages I learned. I don’t mean to bash R (language wars are boring) as it is a fantastic tool for data analysis, but I often find myself asking “how do I solve this without a for loop?” since [loops are slow in R](http://adv-r.had.co.nz/Performance.html). In Julia, I have fewer performance obstacles, so my questions are more along the lines of “what are the methods I’m trying to accomplish this task with?”. If I can reduce a task to the operations that need to be performed, it becomes easy to write abstract yet performant code that works with any types I throw at it.

Multiple dispatch has become invaluable to how I code, and with Julia you get it along with stellar performance. If you want to see how I use multiple dispatch to get a lot done with very little code, check out my package [OnlineStats.jl](https://github.com/joshday/OnlineStats.jl) for calculating statistics/models on data streams with single-pass algorithms.

I hope you try Julia for yourself and have the same experience I had.

**Come for the speed.  Stay for the productivity.**