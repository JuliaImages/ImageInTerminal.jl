@test supertype(AsciiPixel.BigBlocks)   <: AsciiPixel.ImageEncoder
@test supertype(AsciiPixel.SmallBlocks) <: AsciiPixel.ImageEncoder

@testset "_charof" begin
    @test @inferred(AsciiPixel._charof(0.)) === '⋅'
    @test @inferred(AsciiPixel._charof(.2)) === '░'
    @test @inferred(AsciiPixel._charof(.5)) === '▒'
    @test @inferred(AsciiPixel._charof(.8)) === '▓'
    @test @inferred(AsciiPixel._charof(1.)) === '█'
end

@testset "ascii_encode 8bit small" begin
    @testset "gray square" begin
        img, enc = downscale_small(gray_square, 2, 2)
        @test enc.size === (1, 2)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232;48;5;248m▀\e[38;5;239;48;5;255m▀\e[0m"
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding.
        # So this yields the exact same results as above.
        img, enc = downscale_small(gray_square_alpha, 2, 2)
        @test enc.size === (1, 2)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232;48;5;248m▀\e[38;5;239;48;5;255m▀\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        img, enc = downscale_small(camera_man, 20, 20)
        @test enc.size === (9, 17)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_small_20x20_8bit.txt" res
        # too small size
        img, enc = downscale_small(camera_man, 1, 1)
        @test enc.size === (3, 5)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_small_1x1_8bit.txt" res
        # bigger version
        img, enc = downscale_small(camera_man, 60, 60)
        @test enc.size === (17, 33)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_small_60x60_8bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = downscale_small(lighthouse, 60, 60)
        @test enc.size === (17, 49)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/lighthouse_small_60x60_8bit.txt" res
    end
    @testset "toucan" begin
        img, enc = downscale_small(toucan, 60, 60)
        @test enc.size === (20, 42)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/toucan_small_60x60_8bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 8bit big" begin
    @testset "gray square" begin
        img, enc = downscale_big(gray_square, 4, 4)
        @test enc.size === (2, 4)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;5;232m██\e[38;5;239m██\e[0m"
        @test res[2] == "\e[0m\e[38;5;248m██\e[38;5;255m██\e[0m"
    end
    @testset "transparent gray square" begin
        img, enc = downscale_big(gray_square_alpha, 4, 4)
        @test enc.size === (2, 4)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;5;232m██\e[38;5;239m▓▓\e[0m"
        @test res[2] == "\e[0m\e[38;5;248m░░\e[38;5;255m⋅⋅\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        img, enc = downscale_big(camera_man, 40, 40)
        @test enc.size === (17, 34)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_big_20x20_8bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = downscale_big(lighthouse, 50, 50)
        @test enc.size === (17, 50)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/lighthouse_big_50x50_8bit.txt" res
    end
    @testset "toucan" begin
        img, enc = downscale_big(toucan, 60, 60)
        @test enc.size === (20, 44)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/toucan_big_60x60_8bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 24bit small" begin
    @testset "gray square" begin
        img, enc = downscale_small(gray_square, 2, 2)
        @test enc.size === (1, 2)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding.
        # So this yields the exact same results as above.
        img, enc = downscale_small(gray_square_alpha, 2, 2)
        @test enc.size === (1, 2)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        img, enc = downscale_small(camera_man, 20, 20)
        @test enc.size === (9, 17)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_small_20x20_24bit.txt" res
        # bigger version
        img, enc = downscale_small(camera_man, 60, 60)
        @test enc.size === (17, 33)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_small_60x60_24bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = downscale_small(lighthouse, 60, 60)
        @test enc.size === (17, 49)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/lighthouse_small_60x60_24bit.txt" res
    end
    @testset "toucan" begin
        img, enc = downscale_small(toucan, 60, 60)
        @test enc.size === (20, 42)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/toucan_small_60x60_24bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 24bit big" begin
    @testset "gray square" begin
        img, enc = downscale_big(gray_square, 4, 4)
        @test enc.size === (2, 4)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m██\e[0m"
        @test res[2] == "\e[0m\e[38;2;178;178;178m██\e[38;2;255;255;255m██\e[0m"
    end
    @testset "transparent gray square" begin
        img, enc = downscale_big(gray_square_alpha, 4, 4)
        @test enc.size === (2, 4)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m▓▓\e[0m"
        @test res[2] == "\e[0m\e[38;2;178;178;178m░░\e[38;2;255;255;255m⋅⋅\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        img, enc = downscale_big(camera_man, 40, 40)
        @test enc.size === (17, 34)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/camera_big_20x20_24bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = downscale_big(lighthouse, 50, 50)
        @test enc.size === (17, 50)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/lighthouse_big_50x50_24bit.txt" res
    end
    @testset "toucan" begin
        img, enc = downscale_big(toucan, 60, 60)
        @test enc.size === (20, 44)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/toucan_big_60x60_24bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 8bit small" begin
    @testset "gray line" begin
        img, enc = downscale_small(gray_line, 10)
        @test enc.size === (1, 4)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m█\e[38;5;239m█\e[38;5;248m█\e[38;5;255m█\e[0m"
    end
    @testset "transparent gray line" begin
        img, enc = downscale_small(gray_line_alpha, 10)
        @test enc.size === (1, 4)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m█\e[38;5;239m▓\e[38;5;248m░\e[38;5;255m⋅\e[0m"
    end
    @testset "rgb line" begin
        img, enc = downscale_small(rgb_line, 8)
        @test enc.size === (1, 6)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;18m█\e[38;5;56m█\e[38;5;91m█\e[38;5;126m█\e[38;5;161m█\e[38;5;88m█\e[0m"
    end
end

# ====================================================================

@testset "ascii_encode 8bit big" begin
    @testset "gray line" begin
        img, enc = downscale_big(gray_line, 9)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m██ \e[0m"
        img, enc = downscale_big(gray_line, 12)
        @test enc.size === (1, 12)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[38;5;239m██ \e[38;5;248m██ \e[38;5;255m██ \e[0m"
    end
    @testset "transparent gray line" begin
        img, enc = downscale_big(gray_line_alpha, 10)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m⋅⋅ \e[0m"
        img, enc = downscale_big(gray_line_alpha, 12)
        @test enc.size === (1, 12)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[38;5;239m▓▓ \e[38;5;248m░░ \e[38;5;255m⋅⋅ \e[0m"
    end
    @testset "rgb line" begin
        img, enc = downscale_big(rgb_line, 9)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"
        img, enc = downscale_big(rgb_line, 22)
        @test enc.size === (1, 21)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[38;5;21m██ \e[38;5;56m██ \e[0m … \e[38;5;161m██ \e[38;5;196m██ \e[38;5;196m██ \e[0m"
    end
end

# ====================================================================

@testset "ascii_encode 24bit small" begin
    @testset "gray line" begin
        img, enc = downscale_small(gray_line, 10)
        @test enc.size === (1, 4)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m█\e[38;2;178;178;178m█\e[38;2;255;255;255m█\e[0m"
    end
    @testset "transparent gray line" begin
        img, enc = downscale_small(gray_line_alpha, 10)
        @test enc.size === (1, 4)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m▓\e[38;2;178;178;178m░\e[38;2;255;255;255m⋅\e[0m"
    end
    @testset "rgb line" begin
        img, enc = downscale_small(rgb_line, 8)
        @test enc.size === (1, 6)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;6;0;122m█\e[38;2;47;0;208m█\e[38;2;101;0;154m█\e[38;2;154;0;101m█\e[38;2;208;0;47m█\e[38;2;122;0;6m█\e[0m"
    end
end

# ====================================================================

@testset "ascii_encode 24bit big" begin
    @testset "gray line" begin
        img, enc = downscale_big(gray_line, 9)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m██ \e[0m"
        img, enc = downscale_big(gray_line, 12)
        @test enc.size === (1, 12)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m██ \e[38;2;178;178;178m██ \e[38;2;255;255;255m██ \e[0m"
    end
    @testset "transparent gray line" begin
        img, enc = downscale_big(gray_line_alpha, 10)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m⋅⋅ \e[0m"
        img, enc = downscale_big(gray_line_alpha, 12)
        @test enc.size === (1, 12)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m▓▓ \e[38;2;178;178;178m░░ \e[38;2;255;255;255m⋅⋅ \e[0m"
    end
    @testset "rgb line" begin
        img, enc = downscale_big(rgb_line, 9)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;255m██ \e[0m … \e[38;2;255;0;0m██ \e[0m"
        img, enc = downscale_big(rgb_line, 22)
        @test enc.size === (1, 21)
        res = ensurecolor(ascii_encode, enc, TermColor24bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;255m██ \e[38;2;13;0;242m██ \e[38;2;27;0;228m██ \e[0m … \e[38;2;228;0;27m██ \e[38;2;242;0;13m██ \e[38;2;255;0;0m██ \e[0m"
    end
end

@testset "non-1 indexing" begin
    @testset "rgb line" begin
        img, enc = downscale_small(OffsetArray(rgb_line, (-1,)), 8)
        @test enc.size === (1, 6)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;18m█\e[38;5;56m█\e[38;5;91m█\e[38;5;126m█\e[38;5;161m█\e[38;5;88m█\e[0m"
    end
    @testset "rgb line2" begin
        img, enc = downscale_big(OffsetArray(rgb_line, (2,)), 9)
        @test enc.size === (1, 9)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"
        img, enc = downscale_big(OffsetArray(rgb_line, (-2,)), 22)
        @test enc.size === (1, 21)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[38;5;21m██ \e[38;5;56m██ \e[0m … \e[38;5;161m██ \e[38;5;196m██ \e[38;5;196m██ \e[0m"
    end
    @testset "lighthouse" begin
        img, enc = downscale_small(OffsetArray(lighthouse, (2, -10)), 60, 60)
        @test enc.size === (17, 49)
        res = ensurecolor(ascii_encode, enc, TermColor8bit(), img)
        @test typeof(res) <: Vector{String}
        @test_reference "reference/lighthouse_small_60x60_8bit.txt" res
    end
end

@testset "ascii_display" begin
    @testset "lighthouse 8bit" begin
        img = imresize(lighthouse, (30, 30))
        res = readlines(ensurecolor(  # uses small blocks
            ascii_display, PipeBuffer(), img, TermColor8bit(), (20, 20)
        ))
        @test_reference "reference/display_monarch_20x20_8bit.txt" res
        res = readlines(ensurecolor(  # uses big blocks
            ascii_display, PipeBuffer(), img, TermColor8bit(), (80, 80)
        ))
        @test_reference "reference/display_monarch_80x80_8bit.txt" res
    end
    @testset "monarch 24bit" begin
        img = imresize(monarch, (30, 30))
        res = readlines(ensurecolor(  # uses small blocks
            ascii_display, PipeBuffer(), img, TermColor24bit(), (20, 20)
        ))
        @test_reference "reference/display_monarch_20x20_24bit.txt" res
        res = readlines(ensurecolor(  # uses big blocks
            ascii_display, PipeBuffer(), img, TermColor24bit(), (80, 80)
        ))
        @test_reference "reference/display_monarch_80x80_24bit.txt" res
    end
end
