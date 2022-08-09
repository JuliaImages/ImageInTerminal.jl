using Test, TestImages, ReferenceTests
using CoordinateTransformations
using ImageTransformations
using ImageInTerminal
using XTermColors
using ImageBase
using FileIO

import ImageInTerminal: imshow, set_colormode

include(joinpath(dirname(pathof(XTermColors)), "..", "test", "common.jl"))

ImageInTerminal.ENCODER_BACKEND[] = :XTermColors  # manually disable Sixel
for t in ("tst_baseshow.jl", "tst_imshow.jl", "tst_display.jl", "tst_sixel.jl")
    @testset "$t" begin
        include(t)
    end
end

@testset "color depth" begin
    @test set_colormode(24) == XTermColors.TermColor24bit()
    @test set_colormode(8) == XTermColors.TermColor8bit()
    @test_throws ErrorException set_colormode(1)
end
