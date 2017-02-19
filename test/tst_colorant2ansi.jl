@testset "Not exported Interface" begin
    @test supertype(ImageInTerminal.TermColor256) <: ImageInTerminal.TermColorDepth
    @test supertype(ImageInTerminal.TermColor24bit) <: ImageInTerminal.TermColorDepth

    # This tests if the mapping from RGB to the
    # 256 ansi color codes is correct
    @testset "256 colors" begin
        # reference functions to compare against
        function _ref_col2ansi(r,g,b)
            r6, g6, b6 = map(c->round(Int, 5c), (r, g, b))
            16 + 36 * r6 + 6 * g6 + b6
        end
        function _ref_col2ansi(gr)
            round(Int, 232 + gr * 23)
        end
        @testset "RGB" begin
            for col in rand(RGB, 10)
                r, g, b = red(col), green(col), blue(col)
                ri, gi, bi = map(c->round(Int, 23c), (r, g, b))
                if ri == gi == bi
                    @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor256()) === _ref_col2ansi(r)
                else
                    @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor256()) === _ref_col2ansi(r, g, b)
                end
            end
        end
        @testset "Gray" begin
            for col in rand(Gray, 10)
                r = real(col)
                @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor256()) === _ref_col2ansi(r)
            end
        end
    end

    # This tests if the mapping from RGB to the 24 bit r g b tuples
    # (which are in the set {0,1,...,255}) is correct.
    @testset "24 bit" begin
        @testset "RGB" begin
            for col in rand(RGB, 10)
                r, g, b = red(col), green(col), blue(col)
                ri, gi, bi = map(c->round(Int,255c), (r,g,b))
                @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor24bit()) === (ri, gi, bi)
            end
        end
        @testset "Gray" begin
            for col in rand(Gray, 10)
                r = round(Int, 255*real(col))
                @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor24bit()) === (r, r, r)
            end
        end
    end

    # Internally non RGB Colors should be converted to RGB
    # This tests if the result reflects that assumption
    @testset "Non RGB" begin
        for col_rgb in rand(RGB, 10)
            col_other = convert(HSV, col_rgb)
            @test ImageInTerminal._colorant2ansi(col_rgb, ImageInTerminal.TermColor24bit()) === ImageInTerminal._colorant2ansi(col_other, ImageInTerminal.TermColor24bit())
        end
    end

    # Internally all Alpha Colors should be stripped of their alpha
    # channel. This tests if the result reflects that assumption
    @testset "TransparentColor" begin
        for col in (rand(RGB, 10)..., rand(HSV, 10)...)
            acol = alphacolor(col, rand())
            @test ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor24bit()) === ImageInTerminal._colorant2ansi(acol, ImageInTerminal.TermColor24bit())
        end
    end
end

# Tests that we don't pollute the calling namespace with
# exports that they don't need.
# Also compare functionality against the functions tested above
@testset "Exported Interface" begin
    @testset "Validate exported interface boundaries" begin
        @test_throws UndefVarError TermColor256()
        @test_throws UndefVarError TermColor24bit()
        @test_throws MethodError colorant2ansi(RGB(1.,1.,1.), ImageInTerminal.TermColor256())
        @test_throws MethodError colorant2ansi(RGB(1.,1.,1.), ImageInTerminal.TermColor24bit())
    end

    @testset "256 colors" begin
        for col in (rand(RGB, 10)..., rand(Gray, 10)...)
            # compare against non-exported interface,
            # which we already tested above
            @test colorant2ansi(col) === ImageInTerminal._colorant2ansi(col, ImageInTerminal.TermColor256())
        end
    end

    # Check if exported interface propagatres conversions
    @testset "Non RGB" begin
        for col_rgb in rand(RGB, 10)
            col_other = convert(HSV, col_rgb)
            @test colorant2ansi(col_rgb) === colorant2ansi(col_other)
        end
    end

    # Check if exported interface propagatres conversions
    @testset "TransparentColor" begin
        for col in (rand(RGB, 10)..., rand(HSV, 10)...)
            acol = alphacolor(col, rand())
            @test colorant2ansi(col) === colorant2ansi(acol)
        end
    end
end

