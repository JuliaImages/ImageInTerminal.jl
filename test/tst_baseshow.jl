@testset "256 colors" begin
    ImageInTerminal.use_256()
    io = IOBuffer()
    show(io, MIME"text/plain"(), lena)
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "lena_show_256" res
    io = IOBuffer()
    show(io, MIME"text/plain"(), rgb_line)
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "rgbline_show_256" res
    io = IOBuffer()
    show(io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "colorant_show_256" res
end

@testset "24 bit" begin
    ImageInTerminal.use_24bit()
    io = IOBuffer()
    show(io, MIME"text/plain"(), lena)
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "lena_show_24bit" res
    io = IOBuffer()
    show(io, MIME"text/plain"(), rgb_line)
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "rgbline_show_24bit" res
    io = IOBuffer()
    show(io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    res = replace.(readlines(seek(io,0)), ["\n"], [""])
    @test_reference "colorant_show_24bit" res
end

