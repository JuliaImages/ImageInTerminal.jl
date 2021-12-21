using Test, TestImages, ReferenceTests
using OffsetArrays
using AsciiPixel
using ImageCore

import AsciiPixel: SmallBlocks, BigBlocks, ImageEncoder
import AsciiPixel: colorant2ansi, _colorant2ansi

include("common.jl")

for t in (
    "tst_colorant2ansi.jl",
    "tst_ascii_encode.jl",
)
    @testset "$t" begin
        include(t)
    end
end
