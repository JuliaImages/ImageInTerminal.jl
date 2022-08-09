@testset "display" begin
    # `latex_fraction.png` was generated using:
    # $ julia -e 'using Laxtexify; render(latexify(:(x / y)), MIME("image/png"), name=abspath("latex_fraction"), callshow=false)'
    fn = joinpath(@__DIR__, "latex_fraction.png")

    img = FileIO.load(fn)
    @test prod(size(img)) > 1_000

    io = PipeBuffer()
    dsp = ImageInTerminal.TerminalGraphicDisplay(io)
    display(dsp, MIME("image/png"), img)
    @test length(read(io, String)) > 5_000

    bytes = read(fn)
    dsp = ImageInTerminal.TerminalGraphicDisplay(io)
    display(dsp, MIME("image/png"), bytes)
    @test length(read(io, String)) > 5_000
end
