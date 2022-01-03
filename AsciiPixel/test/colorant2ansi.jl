@testset "Not exported Interface" begin
    @test supertype(TermColor256) <: AsciiPixel.TermColorDepth
    @test supertype(TermColor24bit) <: AsciiPixel.TermColorDepth

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
            enc = TermColor256()
            for col in rand(RGB, 10)
                r, g, b = red(col), green(col), blue(col)
                ri, gi, bi = map(c->round(Int, 23c), (r, g, b))
                if ri == gi == bi
                    @test enc(col) === _ref_col2ansi(r)
                else
                    @test enc(col) === _ref_col2ansi(r, g, b)
                end
            end
        end
        @testset "Gray" begin
            enc = TermColor256()
            for col in rand(Gray, 10)
                r = real(col)
                @test enc(col) === _ref_col2ansi(r)
            end
        end
    end

    # This tests if the mapping from RGB to the 24 bit r g b tuples
    # (which are in the set {0,1,...,255}) is correct.
    @testset "24 bit" begin
        @testset "RGB" begin
            enc = TermColor24bit()
            for col in rand(RGB, 10)
                r, g, b = red(col), green(col), blue(col)
                ri, gi, bi = map(c->round(Int,255c), (r,g,b))
                @test enc(col) === (ri, gi, bi)
            end
        end
        @testset "Gray" begin
            enc = TermColor24bit()
            for col in rand(Gray, 10)
                r = round(Int, 255*real(col))
                @test enc(col) === (r, r, r)
            end
        end
    end

    # Internally non RGB Colors should be converted to RGB
    # This tests if the result reflects that assumption
    @testset "Non RGB" begin
        for enc in [TermColor24bit(), TermColor256()]
            for col_rgb in rand(RGB, 10)
                col_other = convert(HSV, col_rgb)
                @test enc(col_rgb) === enc(col_other)
            end
        end
    end

    # Internally all Alpha Colors should be stripped of their alpha
    # channel. This tests if the result reflects that assumption
    @testset "TransparentColor" begin
        for enc in [TermColor24bit(), TermColor256()]
            for col in (rand(RGB, 10)..., rand(HSV, 10)...)
                acol = alphacolor(col, rand())
                @test enc(col) === enc(acol)
            end
        end
    end
end
