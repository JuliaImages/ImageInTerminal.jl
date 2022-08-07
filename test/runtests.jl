using Test, TestImages, ReferenceTests
using CoordinateTransformations
using ImageTransformations
using ImageInTerminal
using XTermColors
using ImageBase
using FileIO

import ImageInTerminal: imshow

include(joinpath(dirname(pathof(XTermColors)), "..", "test", "common.jl"))

ImageInTerminal.ENCODER_BACKEND[] = :ImageInTerminal  # manually disable Sixel
for t in ("tst_baseshow.jl", "tst_imshow.jl", "tst_display.jl", "tst_sixel.jl")
    @testset "$t" begin
        include(t)
    end
end
