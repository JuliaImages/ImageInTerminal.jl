@testset "Not exported Interface" begin
    @test supertype(ImageInTerminal.TermColor256) <: ImageInTerminal.TermColorDepth
    @test supertype(ImageInTerminal.TermColor24bit) <: ImageInTerminal.TermColorDepth

    @testset "24 bit" begin
        for col in rand(RGB{N8f8}, 10)
            r, g, b = red(col), green(col), blue(col)
            # TODO: is there a cleaner way from N8f8 to UInt8 ?
            ri, gi, bi = map(c->round(Int,255c), (r,g,b))
            @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor24bit()) === (ri, gi, bi)
        end
    end

end

@testset "Exported Interface" begin
    @testset "Validate exported interface boundaries" begin
        @test_throws UndefVarError TermColor256()
        @test_throws UndefVarError TermColor24bit()
        @test_throws MethodError colorant2ansi(RGB(1.,1.,1.), ImageInTerminal.TermColor256())
        @test_throws MethodError colorant2ansi(RGB(1.,1.,1.), ImageInTerminal.TermColor24bit())
    end

    @testset "Non RGB" begin
        for col_rgb in rand(RGB, 10)
            col_other = convert(HSV, col_rgb)
            @test colorant2ansi(col_rgb) === colorant2ansi(col_other)
        end
    end

    @testset "TransparentColor" begin
        for col in (rand(RGB, 10)..., rand(HSV, 10)...)
            acol = alphacolor(col, rand())
            @test colorant2ansi(col) === colorant2ansi(acol)
        end
    end
end

