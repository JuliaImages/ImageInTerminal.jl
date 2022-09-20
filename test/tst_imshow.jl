import OffsetArrays: OffsetArray
import SparseArrays: sprand
import Rotations: RotMatrix

# workaround for github.com/JuliaLang/julia/issues/12711
function _redirect_stdout(f::Function, io::IO)
    old_stdout = stdout
    rd, = redirect_stdout()
    task = @async write(io, rd)
    try
        ret = f()
        Libc.flush_cstdio()
        flush(stdout)
        return ret
    finally
        close(rd)
        redirect_stdout(old_stdout)
        wait(task)
    end
end

@testset "STDOUT" begin
    # make sure it compiles and executes
    for mode in (8, 24)
        set_colormode(mode)
        io = PipeBuffer()
        _redirect_stdout(io) do
            # 2D - Matrix
            @ensurecolor imshow(colorview(RGB, rand(3, 2, 3)))
            println()
            @ensurecolor imshow(colorview(RGB, rand(3, 2, 3)), (2, 3))
            println()
            # 3D
            @ensurecolor imshow(colorview(RGB, rand(3, 3, 4, 2)))
            println()
        end
        @test length(read(io, String)) > 500
    end
end

for mode in (8, 24)
    set_colormode(mode)
    name = "$(mode)bit"
    @testset "$name" begin
        @testset "non colorant" begin
            @test_throws ArgumentError imshow(rand(5, 5))
            @test_throws ArgumentError imshow(sprand(5, 5, 0.5))
        end
        @testset "rgb line" begin
            io = PipeBuffer()
            @ensurecolor imshow(io, rgb_line)
            @test_reference "reference/rgbline_big_$(name).txt" readlines(io)
            io = PipeBuffer()
            @ensurecolor imshow(io, rgb_line, (1, 45))
            @test_reference "reference/rgbline_small1_$(name).txt" readlines(io)
            io = PipeBuffer()
            @ensurecolor imshow(io, rgb_line, (1, 19))
            @test_reference "reference/rgbline_small2_$(name).txt" readlines(io)
        end
        @testset "mandril" begin
            img = imresize(mandril, 10, 10)
            io = PipeBuffer()
            @ensurecolor imshow(io, img)
            @test_reference "reference/mandril_big_$(name).txt" readlines(io)
            io = PipeBuffer()
            @ensurecolor imshow(io, img, (10, 20))
            @test_reference "reference/mandril_small_$(name).txt" readlines(io)
        end
        @testset "ndarray" begin
            img = rgb_line_4d
            io = PipeBuffer()
            @ensurecolor imshow(io, img)
            @test_reference "reference/ndarray_$(name).txt" readlines(io)
        end
    end
end

@testset "imshow 8bit non 1 based indexing" begin
    set_colormode(8)
    @testset "mandril" begin
        img = OffsetArray(imresize(mandril, 10, 10), (-10, 5))
        io = PipeBuffer()
        @ensurecolor imshow(io, img)
        @test_reference "reference/mandril_big_8bit.txt" readlines(io)
    end
    @testset "rotation" begin
        tfm = recenter(RotMatrix(-π / 4), center(lighthouse))
        lhr = ImageTransformations.warp(lighthouse, tfm)
        io = PipeBuffer()
        @ensurecolor imshow(io, lhr)
        @test_reference "reference/lighthouse_rotated.txt" readlines(io)
    end
end

@testset "callback" begin
    img = imresize(mandril, 10, 10)
    io = PipeBuffer()
    fgcols, bgcols = [], []
    callback(I, fgcol, bgcol, chars...) = begin
        push!(fgcols, fgcol)
        push!(bgcols, bgcol)
    end
    @ensurecolor imshow(io, img; callback=callback)
    @test length(fgcols) == prod(size(img))
    @test all(ismissing.(bgcols))
end

set_colormode(8)  # reset to default state
