@testset "Common" begin
    @test AsciiPixel.set_colordepth(8) == TermColor8bit()
    @test AsciiPixel.set_colordepth(24) == TermColor24bit()
    @test_throws ErrorException AsciiPixel.set_colordepth(1)
end

@testset "ascii_display" begin
    # ascii_display(stdout, )
end
