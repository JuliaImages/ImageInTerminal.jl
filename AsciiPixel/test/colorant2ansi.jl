@testset "Not exported Interface" begin
    @test supertype(TermColor256) <: AsciiPixel.TermColorDepth
    @test supertype(TermColor24bit) <: AsciiPixel.TermColorDepth

    # This tests if the mapping from RGB to the
    # 256 ansi color codes is correct
    @testset "256 colors" begin
        #reference functions to compare against
        function _ref_col2ansi(r,g,b)
            r24, g24, b24 = map(c->round(Int, c * 23), (r, g, b))
            if r24 == g24 == b24
                # RGB scale color code
                r24 == 0 && return 17   # 0x000000
                r24 == 9 && return 60   # 0x5f5f5f
                r24 == 12 && return 103 # 0x878787
                r24 == 16 && return 146 # 0xafafaf
                r24 == 19 && return 189 # 0xd7d7d7
                r24 == 23 && return 232 # 0xffffff
                # gray scale color code
                232 + r24
            else
                r6, g6, b6 = map(c->floor(Int, c * 5), (r, g, b))
                17 + 36 * r6 + 6 * g6 + b6
            end
        end
        function _ref_col2ansi(gr)
            val = round(Int, clamp01nan(gr) * 26)
            val == 0 && return 17   # 0x000000
            val > 24 && return 232  # 0xffffff
            return 232 + val
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

        @testset "decoder" begin
            enc = TermColor256()

            @testset "RGB scale" begin
                for idx in 17:232
                    ccode = AsciiPixel.TERMCOLOR256_LOOKUP[idx]
                    c = RGB(reinterpret(ARGB32, ccode))
                    @test enc(c) == idx
                end
            end

            @testset "Gray scale" begin
                for idx in 232:256
                    ccode = AsciiPixel.TERMCOLOR256_LOOKUP[idx]
                    c = Gray(red(RGB(reinterpret(ARGB32, ccode))))
                    @test enc(c) == idx
                end
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
