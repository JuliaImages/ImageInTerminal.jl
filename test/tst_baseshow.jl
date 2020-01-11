_tostring(io) = replace.(replace.(readlines(seek(io,0)), Ref("\n" => "")), Ref("$Int" => "Int64"))

@testset "256 colors" begin
    ImageInTerminal.use_256()
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), lena)
    @test_reference "reference/lena_show_256.txt" _tostring(io)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), rgb_line)
    @test_reference "reference/rgbline_show_256.txt" _tostring(io)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    @test_reference "reference/colorant_show_256.txt" _tostring(io)
end

@testset "24 bit" begin
    ImageInTerminal.use_24bit()
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), lena)
    @test_reference "reference/lena_show_24bit.txt" _tostring(io)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), rgb_line)
    @test_reference "reference/rgbline_show_24bit.txt" _tostring(io)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    @test_reference "reference/colorant_show_24bit.txt" _tostring(io)
end

ImageInTerminal.use_256()
