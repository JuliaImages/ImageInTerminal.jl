using Test, TestImages, ReferenceTests
using CoordinateTransformations
using ImageTransformations
using ImageInTerminal
using AsciiPixel
using ImageBase

import ImageInTerminal: imshow

include(joinpath(dirname(pathof(AsciiPixel)), "..", "test", "common.jl"))

ImageInTerminal.encoder_backend[] = :ImageInTerminal  # manually disable Sixel
for t in ("tst_baseshow.jl", "tst_imshow.jl", "tst_sixel.jl")
    @testset "$t" begin
        include(t)
    end
end
