function _tostring(io; strip_summary=false)
    contents = map(readlines(seek(io, 0))) do line
        replace(strip(line), "$Int" => "Int64")
    end

    # ignore summary
    strip_summary ? contents[2:end] : contents
end

@testset "enable/disable encoding" begin
    old_colormode = ImageInTerminal.colormode[]
    old_should_render_image = ImageInTerminal.should_render_image[]

    ImageInTerminal.enable_encoding()
    @test ImageInTerminal.colormode[] == old_colormode
    @test ImageInTerminal.should_render_image[] == true

    ImageInTerminal.enable_encoding()
    ImageInTerminal.disable_encoding()
    @test ImageInTerminal.colormode[] == old_colormode
    @test ImageInTerminal.should_render_image[] == false

    ImageInTerminal.disable_encoding()
    ImageInTerminal.use_256()
    @test ImageInTerminal.colormode[] == ImageInTerminal.TermColor256()
    @test ImageInTerminal.should_render_image[] == true

    ImageInTerminal.disable_encoding()
    ImageInTerminal.use_24bit()
    @test ImageInTerminal.colormode[] == ImageInTerminal.TermColor24bit()
    @test ImageInTerminal.should_render_image[] == true

    ImageInTerminal.colormode[] = old_colormode
    ImageInTerminal.should_render_image[] = old_should_render_image
end

@testset "no encoding" begin
    ImageInTerminal.disable_encoding()
    io = IOBuffer()
    img = fill(RGB(1.0, 1.0, 1.0), 4, 4)
    show(io, MIME"text/plain"(), img)
    @test_reference "reference/2d_show_raw.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    show(io, MIME"text/plain"(), collect(rgb_line))
    @test_reference "reference/rgbline_show_raw.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    show(io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    @test_reference "reference/colorant_show_raw.txt" _tostring(io)
end

@testset "256 colors" begin
    ImageInTerminal.use_256()
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), monarch)
    @test_reference "reference/monarch_show_256.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), rgb_line)
    @test_reference "reference/rgbline_show_256.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    @test_reference "reference/colorant_show_256.txt" _tostring(io)
end

@testset "24 bit" begin
    ImageInTerminal.use_24bit()
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), monarch)
    @test_reference "reference/monarch_show_24bit.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), rgb_line)
    @test_reference "reference/rgbline_show_24bit.txt" _tostring(io; strip_summary=true)
    io = IOBuffer()
    ensurecolor(show, io, MIME"text/plain"(), RGB(0.5,0.1,0.9))
    @test_reference "reference/colorant_show_24bit.txt" _tostring(io)
end

ImageInTerminal.use_256()
