using Test
using AsciiPixel

@testset "AsciiPixel" begin
    @test_nowarn AsciiPixel.hello("AsciiPixel")
    @test true
end
