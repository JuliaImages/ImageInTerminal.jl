using Test, TestImages, ReferenceTests
using OffsetArrays
using AsciiPixel
using ImageCore

import AsciiPixel: TermColorDepth, TermColor8bit, TermColor24bit
import AsciiPixel: ascii_encode, downscale_big, downscale_small
import AsciiPixel: colorant2ansi, _colorant2ansi

include("common.jl")

for t in (
    "tst_colorant2ansi.jl",
    "tst_ascii_encode.jl",
    "tst_highlevel.jl",
)
    @testset "$t" begin
        include(t)
    end
end
