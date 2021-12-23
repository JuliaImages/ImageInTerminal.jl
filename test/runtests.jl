using Test, TestImages, ReferenceTests
using OffsetArrays, SparseArrays
using CoordinateTransformations
using ImageTransformations
using ImageQualityIndexes
using ImageInTerminal
using ImageMagick
using AsciiPixel
using ImageBase
using Rotations

import ImageInTerminal: imshow, imshow256, imshow24bit

tests = [
    "tst_baseshow.jl",
    "tst_imshow.jl",
]

if VERSION >= v"1.6"
    # Sixel is an additional test target and requires Julia at least v1.6
    # It's not installed with `Pkg.instantiate` because it's not listed in
    # `Project.toml`, but instead be manually added in
    # `.github/workflows/UnitTest.yml` in CI setup time.
    try
        @info "Install additional dependencies"
        using Pkg; Pkg.add(PackageSpec(name="Sixel"))
        using Sixel
        push!(tests, "tst_sixel.jl")
        @info "Sixel test: enabled."
    catch e
        @warn "Sixel test: disabled."
        @warn e
    end
end

include(joinpath(dirname(pathof(AsciiPixel)), "..", "test", "common.jl"))

ImageInTerminal.encoder_backend[] = :ImageInTerminal  # manually disable Sixel
for t in tests
    @testset "$t" begin
        include(t)
    end
end
