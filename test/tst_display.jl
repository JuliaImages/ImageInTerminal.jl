@testset "display" begin
    # `latex_fraction.png` was generated using:
    # $ julia -e 'using Laxtexify; render(latexify(:(x / y)), MIME("image/png"), name=abspath("latex_fraction"), callshow=false)'
    img = FileIO.load("latex_fraction.png")
    dsp = ImageInTerminal.TerminalGraphicDisplay(stdout)
    display(dsp, MIME("image/png"), img)
end
