# ImageInTerminal

[![][action-img]][action-url]
[![][pkgeval-img]][pkgeval-url]
[![][codecov-img]][codecov-url]

`ImageInTerminal` is a drop-in package that once imported changes
how a single `Colorant` and whole `Colorant` arrays (regular images)
are displayed in the interactive REPL.
The displayed images will be downscaled to fit into the size of
your active terminal session.

To activate this package simply import it into your Julia session.

### Without ImageInTerminal

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

### Using ImageInTerminal

```julia
julia> using Images, TestImages, ImageInTerminal

julia> testimage("cameraman")

julia> colorview(RGB, rand(3, 10, 10))
```

<img src="https://github.com/JuliaImages/ImageInTerminal.jl/raw/imgs/example.png" alt="Example" width="500">

### Sixel encoder (Julia 1.6+)

If [`Sixel`](https://github.com/johnnychen94/Sixel.jl) is supported by the terminal, this package will encode
the content using a `Sixel` encoder for large images, and thus bring much better image visualization experience in terminal:

<img src="https://github.com/JuliaImages/ImageInTerminal.jl/raw/imgs/sixel.png" alt="Sixel" width="500">

However, do notice that not all terminals support sixel format.
See [Terminals that support sixel](https://github.com/johnnychen94/Sixel.jl#terminals-that-support-sixel) for more information.

### Display equations

`ImageInTerminal` can be used to display latex equations from [Latexify.jl](https://github.com/korsbo/Latexify.jl), here on `mlterm`:

```julia
using ImageInTerminal, Latexify

render(latexify(:(iħ * (∂Ψ(𝐫, t) / ∂t) = -ħ^2 / 2m * ΔΨ(𝐫, t) + V * Ψ(𝐫, t))), dpi=200)
```

<img src="https://github.com/JuliaImages/ImageInTerminal.jl/raw/imgs/latexify.png" alt="Latexify" width="500">

### 8-bit (256) colors and 24-bit colors

By default this packages will detect if your running terminal supports 24-bit colors (true colors).
If it does, the image will be displayed in 24-bit colors, otherwise it fallbacks to 8-bit (256 colors).
To manually switch between 24-bit and 8-bit colors, you can use the internal helpers:

```julia
using ImageInTerminal
ImageInTerminal.set_colormode(8)
ImageInTerminal.set_colormode(24)
```

Note that 24 bits format only works as expected if your terminal supports it,
otherwise you are likely to get some random outputs.
To check if your terminal supports 24 bits color, you can check if
the environment variable `COLORTERM` is set to `24bit` (or `truecolor`).

Here's how images are displayed in 24-bit colors:

<img src="https://github.com/JuliaImages/ImageInTerminal.jl/raw/imgs/cameraman.png" alt="Cameraman" width="500">

### Enable and disable

If you want to temporarily disable this package, you can call `ImageInTerminal.disable_encoding()`.
To restore the encoding functionality use `ImageInTerminal.enable_encoding()`.

## Troubleshooting

If you see out of place horizontal lines in your Image it means that
your font displays the unicode block-characters in an unfortunate way.
Try changing font or reducing your terminal's line-spacing.
If your font is Source Code Pro, update to the latest version.
It is recommended to use the [JuliaMono](https://juliamono.netlify.app) font.

<!-- URLS -->

[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/ImageInTerminal.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html
[action-img]: https://github.com/JuliaImages/ImageInTerminal.jl/workflows/Unit%20test/badge.svg
[action-url]: https://github.com/JuliaImages/ImageInTerminal.jl/actions
[codecov-img]: https://codecov.io/github/JuliaImages/ImageInTerminal.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/github/JuliaImages/ImageInTerminal.jl?branch=master
