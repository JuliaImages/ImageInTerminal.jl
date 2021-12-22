@testset "STDOUT" begin
    # make sure it compiles and executes
    # TODO: replace this with VT100 tests
    ascii_encode(colorview(RGB, rand(3, 2, 2))); println()
    ascii_encode(colorview(RGB, rand(3, 2, 2)), (2, 2)); println()
    ascii_encode256(colorview(RGB, rand(3, 2, 2))); println()
    ascii_encode256(colorview(RGB, rand(3, 2, 2)), (2, 2)); println()
    ascii_encode24bit(colorview(RGB, rand(3, 2, 2))); println()
    ascii_encode24bit(colorview(RGB, rand(3, 2, 2)), (2, 2)); println()
end

@testset "ascii_encode" begin
    @testset "non colorant" begin
        @test_throws ArgumentError ascii_encode(rand(5, 5))
        @test_throws ArgumentError ascii_encode(sprand(5, 5, .5))
    end
    @testset "monarch" begin
        img = imresize(monarch, 10, 10)
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_big_ascii_encode.txt" res
    end
    @testset "ndarray" begin
        img = rgb_line_4d
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img)
        res = readlines(io)
        @test_reference "reference/ndarray_ascii_encode.txt" res
    end
end

@testset "ascii_encode256" begin
    @testset "non colorant" begin
        @test_throws ArgumentError ascii_encode256(rand(5, 5))
        @test_throws ArgumentError ascii_encode256(sprand(5, 5, .5))
    end
    @testset "rgb line" begin
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, rgb_line)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_big_ascii_encode256.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, rgb_line, (1, 45))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_small1_ascii_encode256.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, rgb_line, (1, 19))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_small2_ascii_encode256.txt" res
    end
    @testset "monarch" begin
        img = imresize(monarch, 10, 10)
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_big_ascii_encode256.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img, (10, 20))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_small_ascii_encode256.txt" res
    end
    @testset "ndarray" begin
        img = rgb_line_4d
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img)
        res = readlines(io)
        @test_reference "reference/ndarray_ascii_encode256.txt" res
    end
end

@testset "ascii_encode24bit" begin
    @testset "non colorant" begin
        @test_throws ArgumentError ascii_encode24bit(rand(5, 5))
        @test_throws ArgumentError ascii_encode24bit(sprand(5, 5, .5))
    end
    @testset "rgb line" begin
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, rgb_line)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_big_ascii_encode24bit.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, rgb_line, (1, 45))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_small1_ascii_encode24bit.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, rgb_line, (1, 19))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/rgbline_small2_ascii_encode24bit.txt" res
    end
    @testset "monarch" begin
        img = imresize(monarch, 10, 10)
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, img)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_big_ascii_encode24bit.txt" res
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, img, (10, 20))
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_small_ascii_encode24bit.txt" res
    end
    @testset "ndarray" begin
        img = rgb_line_4d
        io = PipeBuffer()
        ensurecolor(ascii_encode24bit, io, img)
        res = readlines(io)
        @test_reference "reference/ndarray_ascii_encode24bit.txt" res
    end
end

@testset "ascii_encode non1" begin
    @testset "monarch" begin
        img = OffsetArray(imresize(monarch, 10, 10), (-10, 5))
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, img)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_big_ascii_encode.txt" res
    end
    @testset "rotation" begin
        tfm = recenter(RotMatrix(-π / 4), center(lighthouse))
        lhr = ImageTransformations.warp(lighthouse, tfm)
        io = PipeBuffer()
        ensurecolor(ascii_encode256, io, lhr)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/lighthouse_rotated.txt" res
    end
end
