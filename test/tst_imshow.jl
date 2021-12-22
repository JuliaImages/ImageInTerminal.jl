@testset "STDOUT" begin
    # make sure it compiles and executes
    for func in (imshow, imshow256, imshow24bit)
        # 2D - Matrix
        func(colorview(RGB, rand(3, 2, 3))); println()
        func(colorview(RGB, rand(3, 2, 3)), (2, 3)); println()
        # 3D
        func(colorview(RGB, rand(3, 3, 4, 2))); println()
    end
end

for name in ("imshow", "imshow256", "imshow24bit")
    func = getfield(Main, Symbol(name))
    @testset "$name" begin
        @testset "non colorant" begin
            @test_throws ArgumentError func(rand(5, 5))
            @test_throws ArgumentError func(sprand(5, 5, .5))
        end
        @testset "rgb line" begin
            io = PipeBuffer()
            ensurecolor(func, io, rgb_line)
            res = replace.(readlines(io), Ref("\n"=>""))
            @test_reference "reference/rgbline_big_$(name).txt" res
            io = PipeBuffer()
            ensurecolor(func, io, rgb_line, (1, 45))
            res = replace.(readlines(io), Ref("\n"=>""))
            @test_reference "reference/rgbline_small1_$(name).txt" res
            io = PipeBuffer()
            ensurecolor(func, io, rgb_line, (1, 19))
            res = replace.(readlines(io), Ref("\n"=>""))
            @test_reference "reference/rgbline_small2_$(name).txt" res
        end
        @testset "monarch" begin
            img = imresize(monarch, 10, 10)
            io = PipeBuffer()
            ensurecolor(func, io, img)
            res = replace.(readlines(io), Ref("\n"=>""))
            @test_reference "reference/monarch_big_$(name).txt" res
            io = PipeBuffer()
            ensurecolor(func, io, img, (10, 20))
            res = replace.(readlines(io), Ref("\n"=>""))
            @test_reference "reference/monarch_small_$(name).txt" res
        end
        @testset "ndarray" begin
            img = rgb_line_4d
            io = PipeBuffer()
            ensurecolor(func, io, img)
            @test_reference "reference/ndarray_$(name).txt" readlines(io)
        end
    end
end

@testset "imshow256 non1" begin
    @testset "monarch" begin
        img = OffsetArray(imresize(monarch, 10, 10), (-10, 5))
        io = PipeBuffer()
        ensurecolor(imshow256, io, img)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/monarch_big_imshow256.txt" res
    end
    @testset "rotation" begin
        tfm = recenter(RotMatrix(-π / 4), center(lighthouse))
        lhr = ImageTransformations.warp(lighthouse, tfm)
        io = PipeBuffer()
        ensurecolor(imshow256, io, lhr)
        res = replace.(readlines(io), Ref("\n"=>""))
        @test_reference "reference/lighthouse_rotated.txt" res
    end
end
