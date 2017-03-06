# ImageInTerminal

[![Build Status](https://travis-ci.org/JuliaImages/ImageInTerminal.jl.svg?branch=master)](https://travis-ci.org/JuliaImages/ImageInTerminal.jl)
[![Appveyor](https://ci.appveyor.com/api/projects/status/1b63qanrofre1rd2?svg=true)](https://ci.appveyor.com/project/Evizero/imageinterminal-jl)
[![codecov.io](http://codecov.io/github/JuliaImages/ImageInTerminal.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaImages/ImageInTerminal.jl?branch=master)

ImageInTerminal.jl is a drop-in package that once imported
changes a how a single `Colorant` and whole `Colorant` arrays (i.e.
Images) are displayed in the interactive REPL.
The displayed images will be downscaled to fit into the size of
your active terminal session.

To activate this package simply import it into your Julia session.
By default this packages uses 256 colors. If your terminal supports
24 bit colors you can make use of them by typing the following:

```julia
using ImageInTerminal
ImageInTerminal.use_24bit()
````

### Without this package

```julia
julia> using Images, TestImages

julia> testimage("cameraman")
512×512 Array{Gray{N0f8},2}:
 Gray{N0f8}(0.612)  Gray{N0f8}(0.616)  …  Gray{N0f8}(0.596)
 Gray{N0f8}(0.612)  Gray{N0f8}(0.616)     Gray{N0f8}(0.596)
 Gray{N0f8}(0.62)   Gray{N0f8}(0.616)     Gray{N0f8}(0.596)
 Gray{N0f8}(0.612)  Gray{N0f8}(0.616)  …  Gray{N0f8}(0.6)
 Gray{N0f8}(0.62)   Gray{N0f8}(0.616)     Gray{N0f8}(0.6)
 ⋮                                     ⋱
 Gray{N0f8}(0.435)  Gray{N0f8}(0.439)     Gray{N0f8}(0.439)
 Gray{N0f8}(0.494)  Gray{N0f8}(0.475)  …  Gray{N0f8}(0.467)
 Gray{N0f8}(0.475)  Gray{N0f8}(0.482)     Gray{N0f8}(0.435)
 Gray{N0f8}(0.475)  Gray{N0f8}(0.482)  …  Gray{N0f8}(0.435)
 Gray{N0f8}(0.475)  Gray{N0f8}(0.482)     Gray{N0f8}(0.435)

julia> colorview(RGB, rand(3, 10, 10))
10×10 Array{RGB{Float64},2}:
 RGB{Float64}(0.272693,0.183303,0.0411779)  …  RGB{Float64}(0.743438,0.903394,0.0491672)
 RGB{Float64}(0.035006,0.220871,0.377436)      RGB{Float64}(0.341061,0.145152,0.675675)
 RGB{Float64}(0.164915,0.275161,0.737311)      RGB{Float64}(0.636575,0.460115,0.255893)
 RGB{Float64}(0.656064,0.904043,0.796598)      RGB{Float64}(0.764059,0.573298,0.373081)
 RGB{Float64}(0.203784,0.682884,0.61882)       RGB{Float64}(0.544405,0.934227,0.995363)
 RGB{Float64}(0.906384,0.820926,0.308954)   …  RGB{Float64}(0.00728851,0.996279,0.620743)
 RGB{Float64}(0.574717,0.423059,0.306321)      RGB{Float64}(0.506259,0.138856,0.322121)
 RGB{Float64}(0.0372145,0.60332,0.121911)      RGB{Float64}(0.591279,0.74032,0.876621)
 RGB{Float64}(0.328746,0.69418,0.397904)       RGB{Float64}(0.90115,0.734102,0.893911)
 RGB{Float64}(0.422224,0.914328,0.773111)      RGB{Float64}(0.448258,0.955572,0.0445449)
```

### With this package

```julia
julia> using Images, TestImages, ImageInTerminal

julia> testimage("cameraman")

julia> colorview(RGB, rand(3, 10, 10))
```

![ImageInTerminal](https://cloud.githubusercontent.com/assets/10854026/22923639/92e3b164-f2a2-11e6-85ea-b92bdc4a63e0.png)

## Troubleshooting

If you see out of place horizontal lines in your Image it means
that your font displays the utilized unicode block-characters
in an unfortunate way. Try changing font or reducing your
terminal's line-spacing. If your font is Source Code Pro, update to
the latest version.

