function _tostring(io; strip_summary=false)
    contents = map(readlines(io)) do line
        replace(strip(line), "$Int"=>"Int64")
    end
    strip_summary ? contents[2:end] : contents  # ignore summary
end

@testset "enable/disable encoding" begin
    old_should_render_image = ImageInTerminal.should_render_image[]
    old_colormode = AsciiPixel.colormode[]

    ImageInTerminal.enable_encoding()
    @test ImageInTerminal.should_render_image[] == true
    @test AsciiPixel.colormode[] == old_colormode

    ImageInTerminal.disable_encoding()
    @test ImageInTerminal.should_render_image[] == false
    @test AsciiPixel.colormode[] == old_colormode

    ImageInTerminal.should_render_image[] = old_should_render_image
    AsciiPixel.colormode[] = old_colormode
end

@testset "no encoding" begin
    ImageInTerminal.disable_encoding()
    io = PipeBuffer()
    img = fill(RGB(1., 1., 1.), 4, 4)
    show(io, MIME"text/plain"(), img)
    @test_reference "reference/2d_show_raw.txt" _tostring(io; strip_summary=true)
    io = PipeBuffer()
    show(io, MIME"text/plain"(), collect(rgb_line))
    @test_reference "reference/rgbline_show_raw.txt" _tostring(io; strip_summary=true)
    io = PipeBuffer()
    show(io, MIME"text/plain"(), RGB(.5, .1, .9))
    @test_reference "reference/colorant_show_raw.txt" _tostring(io)
end

for depth in (24, 8)
    @testset "$depth bit color" begin
        ImageInTerminal.enable_encoding()
        AsciiPixel.set_colormode(depth)
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), monarch)
        @test_reference "reference/monarch_show_$(depth)bit.txt" _tostring(io; strip_summary=true)
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), rgb_line)
        @test_reference "reference/rgbline_show_$(depth)bit.txt" _tostring(io; strip_summary=true)
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), RGB(.5, .1, .9))
        @test_reference "reference/colorant_show_$(depth)bit.txt" _tostring(io)
    end
end

AsciiPixel.set_colormode(8)  # paranoid
