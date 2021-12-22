using ImageTransformations, CoordinateTransformations
using Test, TestImages, ReferenceTests
using OffsetArrays, SparseArrays
using AsciiPixel
using ImageCore
using Rotations

import AsciiPixel: TermColorDepth, TermColor256, TermColor24bit
import AsciiPixel: SmallBlocks, BigBlocks, ImageEncoder
import AsciiPixel: ascii_encode24bit, ascii_encode256
import AsciiPixel: colorant2ansi, _colorant2ansi

include("common.jl")

for t in (
    "tst_colorant2ansi.jl",
    "tst_ascii_encode.jl",
    "tst_imshow.jl",
)
    @testset "$t" begin
        include(t)
    end
end
