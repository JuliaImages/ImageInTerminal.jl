# common test statements for ImageInTerminal and AsciiPixel

# define some test images
gray_square = colorview(Gray, N0f8[0.0 0.3; 0.7 1])
gray_square_alpha = colorview(GrayA, N0f8[0.0 0.3; 0.7 1], N0f8[1 0.7; 0.3 0])
gray_line = colorview(Gray, N0f8[0.0, 0.3, 0.7, 1])
gray_line_alpha = colorview(GrayA, N0f8[0.0, 0.3, 0.7, 1], N0f8[1, 0.7, 0.3, 0])
rgb_line = colorview(
    RGB, range(0; stop=1, length=20), zeroarray, range(1; stop=0, length=20)
)
rgb_line_4d = repeat(repeat(rgb_line', 1, 1, 1, 1), 1, 1, 2, 2)

camera_man = testimage("camera")  # .tif
lighthouse = testimage("lighthouse")  # .png
toucan = testimage("toucan")  # .png
mandril = testimage("mandril_color")  # .tif

macro ensurecolor(ex)
    quote
        _ensure_color(old_color) = begin
            try
                @eval Base have_color = true
                return $(esc(ex))
            finally
                Core.eval(Base, :(have_color = $old_color))
            end
        end
        _ensure_color(Base.have_color)
    end
end
