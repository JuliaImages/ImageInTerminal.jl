using Test, TestImages, ReferenceTests
using ImageTransformations
using OffsetArrays
using AsciiPixel
using ImageBase

import AsciiPixel: TermColorDepth, TermColor8bit, TermColor24bit
import AsciiPixel: ascii_encode, _downscale_small, _downscale_big
import AsciiPixel: colorant2ansi, _colorant2ansi

include("common.jl")

function check_encoded(res::Vector{String}, expected::Vector{String})
    @test length(res) === length(expected)
    @test all(res .== expected)
end

for t in ("tst_colorant2ansi.jl", "tst_ascii.jl")
    @testset "$t" begin
        include(t)
    end
end

@testset "Color depth" begin
    @test AsciiPixel.set_colormode(8) == TermColor8bit()
    @test AsciiPixel.set_colormode(24) == TermColor24bit()
    @test_throws ErrorException AsciiPixel.set_colormode(1)
end
