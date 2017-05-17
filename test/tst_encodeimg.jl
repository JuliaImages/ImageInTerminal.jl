@test supertype(ImageInTerminal.BigBlocks) <: ImageInTerminal.ImageEncoder
@test supertype(ImageInTerminal.SmallBlocks) <: ImageInTerminal.ImageEncoder

@testset "_charof" begin
    @test @inferred(ImageInTerminal._charof(0.0)) === '⋅'
    @test @inferred(ImageInTerminal._charof(0.2)) === '░'
    @test @inferred(ImageInTerminal._charof(0.5)) === '▒'
    @test @inferred(ImageInTerminal._charof(0.8)) === '▓'
    @test @inferred(ImageInTerminal._charof(1.0)) === '█'
end

@testset "encodeimg 256 small" begin
    @testset "gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), gray_square, 2, 2)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 2
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232;48;5;248m▀\e[38;5;239;48;5;255m▀\e[0m"
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding.
        # So this yields the exact same results as above.
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), gray_square_alpha, 2, 2)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 2
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232;48;5;248m▀\e[38;5;239;48;5;255m▀\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), camera_man, 20, 20)
        @test typeof(res) <: Vector{String}
        @test h === 9
        @test w === 17
        @test_reference "camera_small_20x20_256" res
        # too small size
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), camera_man, 1, 1)
        @test typeof(res) <: Vector{String}
        @test h === 3
        @test w === 5
        @test_reference "camera_small_1x1_256" res
        # bigger version
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), camera_man, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 33
        @test_reference "camera_small_60x60_256" res
    end
    @testset "lighthouse" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), lighthouse, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 49
        @test_reference "lighthouse_small_60x60_256" res
    end
    @testset "toucan" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), toucan, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 20
        @test w === 42
        @test_reference "toucan_small_60x60_256" res
    end
end

# ====================================================================

@testset "encodeimg 256 big" begin
    @testset "gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_square, 4, 4)
        @test typeof(res) <: Vector{String}
        @test h === 2
        @test w === 4
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;5;232m██\e[38;5;239m██\e[0m"
        @test res[2] == "\e[0m\e[38;5;248m██\e[38;5;255m██\e[0m"
    end
    @testset "transparent gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_square_alpha, 4, 4)
        @test typeof(res) <: Vector{String}
        @test h === 2
        @test w === 4
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;5;232m██\e[38;5;239m▓▓\e[0m"
        @test res[2] == "\e[0m\e[38;5;248m░░\e[38;5;255m⋅⋅\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), camera_man, 40, 40)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 34
        @test_reference "camera_big_20x20_256" res
    end
    @testset "lighthouse" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), lighthouse, 50, 50)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 50
        @test_reference "lighthouse_big_50x50_256" res
    end
    @testset "toucan" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), toucan, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 20
        @test w === 44
        @test_reference "toucan_big_60x60_256" res
    end
end

# ====================================================================

@testset "encodeimg 24bit small" begin
    @testset "gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), gray_square, 2, 2)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 2
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding.
        # So this yields the exact same results as above.
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), gray_square_alpha, 2, 2)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 2
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), camera_man, 20, 20)
        @test typeof(res) <: Vector{String}
        @test h === 9
        @test w === 17
        @test_reference "camera_small_20x20_24bit" res
        # bigger version
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), camera_man, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 33
        @test_reference "camera_small_60x60_24bit" res
    end
    @testset "lighthouse" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), lighthouse, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 49
        @test_reference "lighthouse_small_60x60_24bit" res
    end
    @testset "toucan" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), toucan, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 20
        @test w === 42
        @test_reference "toucan_small_60x60_24bit" res
    end
end

# ====================================================================

@testset "encodeimg 24bit big" begin
    @testset "gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_square, 4, 4)
        @test typeof(res) <: Vector{String}
        @test h === 2
        @test w === 4
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m██\e[0m"
        @test res[2] == "\e[0m\e[38;2;178;178;178m██\e[38;2;255;255;255m██\e[0m"
    end
    @testset "transparent gray square" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_square_alpha, 4, 4)
        @test typeof(res) <: Vector{String}
        @test h === 2
        @test w === 4
        @test length(res) === 2
        @test res[1] == "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m▓▓\e[0m"
        @test res[2] == "\e[0m\e[38;2;178;178;178m░░\e[38;2;255;255;255m⋅⋅\e[0m"
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), camera_man, 40, 40)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 34
        @test_reference "camera_big_20x20_24bit" res
    end
    @testset "lighthouse" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), lighthouse, 50, 50)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 50
        @test_reference "lighthouse_big_50x50_24bit" res
    end
    @testset "toucan" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), toucan, 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 20
        @test w === 44
        @test_reference "toucan_big_60x60_24bit" res
    end
end

# ====================================================================

@testset "encodeimg 256 small" begin
    @testset "gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), gray_line, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 4
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m█\e[38;5;239m█\e[38;5;248m█\e[38;5;255m█\e[0m"
    end
    @testset "transparent gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), gray_line_alpha, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 4
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m█\e[38;5;239m▓\e[38;5;248m░\e[38;5;255m⋅\e[0m"
    end
    @testset "rgb line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), rgb_line, 8)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 8
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m█\e[38;5;56m█\e[38;5;91m█\e[38;5;91m█\e[38;5;126m█\e[38;5;126m█\e[38;5;161m█\e[38;5;196m█\e[0m"
    end
end

# ====================================================================

@testset "encodeimg 256 big" begin
    @testset "gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_line, 9)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m██ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_line, 12)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 12
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[38;5;239m██ \e[38;5;248m██ \e[38;5;255m██ \e[0m"
    end
    @testset "transparent gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_line_alpha, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m⋅⋅ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), gray_line_alpha, 12)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 12
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;232m██ \e[38;5;239m▓▓ \e[38;5;248m░░ \e[38;5;255m⋅⋅ \e[0m"
    end
    @testset "rgb line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), rgb_line, 9)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), rgb_line, 22)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 21
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[38;5;21m██ \e[38;5;56m██ \e[0m … \e[38;5;161m██ \e[38;5;196m██ \e[38;5;196m██ \e[0m"
    end
end

# ====================================================================

@testset "encodeimg 24bit small" begin
    @testset "gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), gray_line, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 4
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m█\e[38;2;178;178;178m█\e[38;2;255;255;255m█\e[0m"
    end
    @testset "transparent gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), gray_line_alpha, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 4
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m▓\e[38;2;178;178;178m░\e[38;2;255;255;255m⋅\e[0m"
    end
    @testset "rgb line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor24bit(), rgb_line, 8)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 8
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;10;0;245m█\e[38;2;44;0;211m█\e[38;2;77;0;178m█\e[38;2;111;0;144m█\e[38;2;144;0;111m█\e[38;2;178;0;77m█\e[38;2;211;0;44m█\e[38;2;245;0;10m█\e[0m"
    end
end

# ====================================================================

@testset "encodeimg 24bit big" begin
    @testset "gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_line, 9)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m██ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_line, 12)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 12
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m██ \e[38;2;178;178;178m██ \e[38;2;255;255;255m██ \e[0m"
    end
    @testset "transparent gray line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_line_alpha, 10)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m⋅⋅ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), gray_line_alpha, 12)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 12
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m▓▓ \e[38;2;178;178;178m░░ \e[38;2;255;255;255m⋅⋅ \e[0m"
    end
    @testset "rgb line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), rgb_line, 9)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;255m██ \e[0m … \e[38;2;255;0;0m██ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor24bit(), rgb_line, 22)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 21
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;2;0;0;255m██ \e[38;2;13;0;242m██ \e[38;2;27;0;228m██ \e[0m … \e[38;2;228;0;27m██ \e[38;2;242;0;13m██ \e[38;2;255;0;0m██ \e[0m"
    end
end

@testset "non-1 indexing" begin
    @testset "rgb line" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), OffsetArray(rgb_line, (-1,)), 8)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 8
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m█\e[38;5;56m█\e[38;5;91m█\e[38;5;91m█\e[38;5;126m█\e[38;5;126m█\e[38;5;161m█\e[38;5;196m█\e[0m"
    end
    @testset "rgb line2" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), OffsetArray(rgb_line, (2,)), 9)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 9
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.BigBlocks(), ImageInTerminal.TermColor256(), OffsetArray(rgb_line, (-2,)), 22)
        @test typeof(res) <: Vector{String}
        @test h === 1
        @test w === 21
        @test length(res) === 1
        @test res[1] == "\e[0m\e[38;5;21m██ \e[38;5;21m██ \e[38;5;56m██ \e[0m … \e[38;5;161m██ \e[38;5;196m██ \e[38;5;196m██ \e[0m"
    end
    @testset "lighthouse" begin
        res, h, w = ensurecolor(ImageInTerminal.encodeimg, ImageInTerminal.SmallBlocks(), ImageInTerminal.TermColor256(), OffsetArray(lighthouse, (2,-10)), 60, 60)
        @test typeof(res) <: Vector{String}
        @test h === 17
        @test w === 49
        @test_reference "lighthouse_small_60x60_256" res
    end
end
