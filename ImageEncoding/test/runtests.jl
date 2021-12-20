using Test, TestImages, ReferenceTests
using ImageEncoding
using OffsetArrays
using ImageCore

include("common.jl")

for t in (
    "tst_colorant2ansi.jl",
    "tst_encodeimg.jl",
)
    @testset "$t" begin
        include(t)
    end
end
