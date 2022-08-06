function _tostring(io; strip_summary=false)
    contents = map(readlines(io)) do line
        replace(strip(line), "$Int" => "Int64")
    end
    strip_summary ? contents[2:end] : contents  # ignore summary
end

@testset "enable/disable encoding" begin
    old_should_render_image = ImageInTerminal.should_render_image[]
    old_colormode = XTermColors.colormode[]

    ImageInTerminal.enable_encoding()
    @test ImageInTerminal.should_render_image[] == true
    @test XTermColors.colormode[] == old_colormode

    ImageInTerminal.disable_encoding()
    @test ImageInTerminal.should_render_image[] == false
    @test XTermColors.colormode[] == old_colormode

    ImageInTerminal.should_render_image[] = old_should_render_image
    XTermColors.colormode[] = old_colormode
end

@testset "no encoding" begin
    ImageInTerminal.disable_encoding()
    io = PipeBuffer()
    img = fill(RGB(1.0, 1.0, 1.0), 4, 4)
    show(io, MIME"text/plain"(), img)
    @test_reference "reference/2d_show_raw.txt" _tostring(io; strip_summary=true)
    io = PipeBuffer()
    show(io, MIME"text/plain"(), collect(rgb_line))
    @test_reference "reference/rgbline_show_raw.txt" _tostring(io; strip_summary=true)
    io = PipeBuffer()
    show(io, MIME"text/plain"(), RGB(0.5, 0.1, 0.9))
    @test_reference "reference/colorant_show_raw.txt" _tostring(io)
end

for depth in (24, 8)
    @testset "$depth bit color" begin
        ImageInTerminal.enable_encoding()
        XTermColors.set_colormode(depth)
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), mandril)
        @test_reference "reference/mandril_show_$(depth)bit.txt" _tostring(
            io; strip_summary=true
        )
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), rgb_line)
        @test_reference "reference/rgbline_show_$(depth)bit.txt" _tostring(
            io; strip_summary=true
        )
        io = PipeBuffer()
        @ensurecolor show(io, MIME"text/plain"(), RGB(0.5, 0.1, 0.9))
        @test_reference "reference/colorant_show_$(depth)bit.txt" _tostring(io)
    end
end

XTermColors.set_colormode(8)  # paranoid
