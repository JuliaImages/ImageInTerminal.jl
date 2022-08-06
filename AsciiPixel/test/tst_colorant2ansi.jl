@testset "Not exported Interface" begin
    @test supertype(TermColor8bit) <: TermColorDepth
    @test supertype(TermColor24bit) <: TermColorDepth

    # This tests if the mapping from RGB to the
    # 8bit (256) ansi color codes is correct
    @testset "8bit colors" begin
        # reference functions to compare against
        # function _ref_col2ansi(r, g, b)
        #     r24, g24, b24 = map(c->round(Int, 23c), (r, g, b))
        #     if r24 == g24 == b24
        #         # RGB scale color code
        #         r24 == 0 && return 16   # 0x000000
        #         r24 == 9 && return 59   # 0x5f5f5f
        #         r24 == 12 && return 102 # 0x878787
        #         r24 == 16 && return 145 # 0xafafaf
        #         r24 == 19 && return 188 # 0xd7d7d7
        #         r24 == 23 && return 231 # 0xffffff
        #         # gray scale color code
        #         232 + r24
        #     else
        #         r6, g6, b6 = map(c -> round(Int, 5c), (r, g, b))
        #         16 + 36r6 + 6g6 + b6
        #     end
        # end
        # function _ref_col2ansi(gr)
        #     val = round(Int, 23clamp01nan(gr))
        #     val == 0 && return 0   # 0x000000
        #     val > 24 && return 231  # 0xffffff
        #     232 + val
        # end
        # @testset "RGB" begin
        #     for col in rand(RGB, 10)
        #         r, g, b = red(col), green(col), blue(col)
        #         ri, gi, bi = map(c -> round(Int, 23c), (r, g, b))
        #         if ri == gi == bi
        #             @test _colorant2ansi(col, TermColor8bit()) === _ref_col2ansi(r)
        #         else
        #             @test _colorant2ansi(col, TermColor8bit()) === _ref_col2ansi(r, g, b)
        #         end
        #     end
        # end
        # @testset "Gray" begin
        #     for col in rand(Gray, 10)
        #         r = real(col)
        #         @test _colorant2ansi(col, TermColor8bit()) === _ref_col2ansi(r)
        #     end
        # end

        @testset "decoder" begin
            enc = TermColor8bit()

            @testset "RGB scale" begin
                for idx in 16:231
                    ccode = AsciiPixel.TERMCOLOR256_LOOKUP[1 + idx]
                    c = RGB(reinterpret(ARGB32, ccode))
                    @test enc(c) == (idx == 16 ? 0 : idx)
                end
            end

            @testset "Gray scale" begin
                for idx in 232:255
                    ccode = AsciiPixel.TERMCOLOR256_LOOKUP[1 + idx]
                    c = Gray(red(RGB(reinterpret(ARGB32, ccode))))
                    @test enc(c) == idx
                end
            end
        end
    end

    # This tests if the mapping from RGB to the 24 bit r g b tuples
    # (which are in the set {0,1,...,255}) is correct.
    @testset "24 bit colors" begin
        @testset "RGB" begin
            for col in rand(RGB, 10)
                r, g, b = red(col), green(col), blue(col)
                ri, gi, bi = map(c -> round(Int, 255c), (r, g, b))
                @test _colorant2ansi(col, TermColor24bit()) === (ri, gi, bi)
            end
        end
        @testset "Gray" begin
            for col in rand(Gray, 10)
                r = round(Int, 255real(col))
                @test _colorant2ansi(col, TermColor24bit()) === (r, r, r)
            end
        end
    end

    # Internally non RGB Colors should be converted to RGB
    # This tests if the result reflects that assumption
    @testset "Non RGB" begin
        for col_rgb in rand(RGB, 10)
            col_other = convert(HSV, col_rgb)
            @test _colorant2ansi(col_rgb, TermColor24bit()) ===
                _colorant2ansi(col_other, TermColor24bit())
        end
    end

    # Internally all Alpha Colors should be stripped of their alpha
    # channel. This tests if the result reflects that assumption
    @testset "TransparentColor" begin
        for col in (rand(RGB, 10)..., rand(HSV, 10)...)
            acol = alphacolor(col, rand())
            @test _colorant2ansi(col, TermColor24bit()) ===
                _colorant2ansi(acol, TermColor24bit())
        end
    end
end

# Tests that we don't pollute the calling namespace with
# exports that they don't need.
# Also compare functionality against the functions tested above
@testset "Exported Interface" begin
    @testset "Validate exported interface boundaries" begin
        @test_throws MethodError colorant2ansi(RGB(1.0, 1.0, 1.0), TermColor8bit())
        @test_throws MethodError colorant2ansi(RGB(1.0, 1.0, 1.0), TermColor24bit())
    end

    @testset "8bit colors" begin
        for col in (rand(RGB, 10)..., rand(Gray, 10)...)
            # compare against non-exported interface,
            # which we already tested above
            @test colorant2ansi(col) === _colorant2ansi(col, TermColor8bit())
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
