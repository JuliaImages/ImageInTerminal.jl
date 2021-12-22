@testset "Common" begin
    @test AsciiPixel.set_colordepth(8) == TermColor8bit()
    @test AsciiPixel.set_colordepth(24) == TermColor24bit()
    @test AsciiPixel.set_colordepth("8bit") == TermColor8bit()
    @test AsciiPixel.set_colordepth("24bit") == TermColor24bit()
    @test AsciiPixel.set_colordepth("8-bit") == TermColor8bit()
    @test AsciiPixel.set_colordepth("24-bit") == TermColor24bit()
    @test_throws ErrorException AsciiPixel.set_colordepth(1)
    @test AsciiPixel.set_colordepth("AsciiPixel, please set the color depth to 24") == TermColor24bit()
end
