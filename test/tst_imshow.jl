rgb_line = colorview(RGB, linspace(0,1,20), zeroarray, linspace(1,0,20))
lena = testimage("lena")

@testset "STDOUT" begin
    # make sure it compiles and executes
    # TODO: replace this with VT100 tests
    imshow(colorview(RGB, rand(3,2,2))); println()
    imshow(colorview(RGB, rand(3,2,2)), (2,2)); println()
    imshow256(colorview(RGB, rand(3,2,2))); println()
    imshow256(colorview(RGB, rand(3,2,2)), (2,2)); println()
    imshow24bit(colorview(RGB, rand(3,2,2))); println()
    imshow24bit(colorview(RGB, rand(3,2,2)), (2,2)); println()
end

@testset "imshow" begin
    @testset "lena" begin
        img = imresize(lena, 10, 10)
        io = IOBuffer()
        imshow(io, img)
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "lena_big_imshow" res
    end
end

@testset "imshow256" begin
    @testset "rgb line" begin
        io = IOBuffer()
        imshow256(io, rgb_line)
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_big_imshow256" res
        io = IOBuffer()
        imshow256(io, rgb_line, (1, 45))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_small1_imshow256" res
        io = IOBuffer()
        imshow256(io, rgb_line, (1, 19))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_small2_imshow256" res
    end
    @testset "lena" begin
        img = imresize(lena, 10, 10)
        io = IOBuffer()
        imshow256(io, img)
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "lena_big_imshow256" res
        io = IOBuffer()
        imshow256(io, img, (10, 20))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "lena_small_imshow256" res
    end
end

@testset "imshow24bit" begin
    @testset "rgb line" begin
        io = IOBuffer()
        imshow24bit(io, rgb_line)
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_big_imshow24bit" res
        io = IOBuffer()
        imshow24bit(io, rgb_line, (1, 45))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_small1_imshow24bit" res
        io = IOBuffer()
        imshow24bit(io, rgb_line, (1, 19))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "rgbline_small2_imshow24bit" res
    end
    @testset "lena" begin
        img = imresize(lena, 10, 10)
        io = IOBuffer()
        imshow24bit(io, img)
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "lena_big_imshow24bit" res
        io = IOBuffer()
        imshow24bit(io, img, (10, 20))
        res = replace.(readlines(seek(io,0)), ["\n"], [""])
        @test_reference "lena_small_imshow24bit" res
    end
end

