using Test
using AsciiPixel
using ImageBase
using AsciiPixel: TermColorDepth, TermColor256, TermColor24bit
using AsciiPixel: colorant2ansi, _colorant2ansi

@testset "AsciiPixel" begin
    include("colorant2ansi.jl")
end
