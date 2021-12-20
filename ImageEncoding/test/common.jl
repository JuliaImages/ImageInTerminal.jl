# common test files for ImageInTerminal and ImageEncoding

# define some test images
gray_square = colorview(Gray, N0f8[0. 0.3; 0.7 1])
gray_square_alpha = colorview(GrayA, N0f8[0. 0.3; 0.7 1], N0f8[1 0.7; 0.3 0])
gray_line = colorview(Gray, N0f8[0., 0.3, 0.7, 1])
gray_line_alpha = colorview(GrayA, N0f8[0., 0.3, 0.7, 1], N0f8[1, 0.7, 0.3, 0])
rgb_line = colorview(RGB, range(0, stop=1, length=20), zeroarray, range(1, stop=0, length=20))
rgb_line_4d = repeat(repeat(rgb_line', 1, 1, 1, 1), 1, 1, 2, 2)

camera_man = testimage("camera")
lighthouse = testimage("lighthouse")
toucan = testimage("toucan")
lena = testimage("lena_color_256")

function ensurecolor(f, args...)
    old_color = Base.have_color
    try
        Core.eval(Base, :(have_color = true))
        return f(args...)
    finally
        Core.eval(Base, :(have_color = $old_color))
    end
end
