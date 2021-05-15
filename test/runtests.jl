using ImageInTerminal, ImageCore
using TestImages, ImageTransformations, CoordinateTransformations
using Rotations, OffsetArrays
using SparseArrays
using ImageQualityIndexes
using Test, ReferenceTests

function ensurecolor(f, args...)
    old_color = Base.have_color
    try
        Core.eval(Base, :(have_color = true))
        return f(args...)
    finally
        Core.eval(Base, :(have_color = $old_color))
    end
end

# ====================================================================

# define some test images
gray_square = colorview(Gray, N0f8[0. 0.3; 0.7 1])
gray_square_alpha = colorview(GrayA, N0f8[0. 0.3; 0.7 1], N0f8[1 0.7; 0.3 0])
gray_line = colorview(Gray, N0f8[0., 0.3, 0.7, 1])
gray_line_alpha = colorview(GrayA, N0f8[0., 0.3, 0.7, 1], N0f8[1, 0.7, 0.3, 0])
rgb_line = colorview(RGB, range(0, stop=1, length=20), zeroarray, range(1, stop=0, length=20))
rgb_line_4d = repeat(repeat(rgb_line', 1, 1, 1, 1), 1, 1, 2, 2)

camera_man = testimage("camera")
lighthouse = testimage("lighthouse")
toucan = testimage("toucan")
lena = testimage("lena_color_256")

# ====================================================================

tests = [
    "tst_colorant2ansi.jl",
    "tst_encodeimg.jl",
    "tst_imshow.jl",
    "tst_baseshow.jl",
]


if VERSION >= v"1.6"
    # Sixel is an additional test target and requires Julia at least v1.6
    # It's not installed with `Pkg.instantiate` because it's not listed in
    # `Project.toml`, but instead be manually added in
    # `.github/workflows/UnitTest.yml` in CI setup time.
    try
        @info "Install additional dependencies"
        using Pkg
        Pkg.add(PackageSpec(name="Sixel"))
        using Sixel
        push!(tests, "sixel.jl")
        @info "Sixel test: enabled."
    catch e
        @warn "Sixel test: disabled."
        @warn e
    end
end

ImageInTerminal.encoder_backend[1] = :ImageInTerminal # manually disable Sixel
for t in tests
    @testset "$t" begin
        include(t)
    end
end
