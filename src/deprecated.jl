function imshow256(args...)
    Base.depwarn(
        "`imshow256(x)` is deprecated, use `AsciiPixel.set_colormode(8)` and `imshow(x)`",
        :imshow256
    )
    old_colormode = AsciiPixel.colormode[]
    AsciiPixel.set_colormode(8)
    imshow(args...)
    AsciiPixel.colormode[] = old_colormode
end

function imshow24bit(args...)
    Base.depwarn(
        "`imshow24bit(x)` is deprecated, use `AsciiPixel.set_colormode(24)` and `imshow(x)`",
        :imshow24bit
    )
    old_colormode = AsciiPixel.colormode[]
    AsciiPixel.set_colormode(24)
    imshow(args...)
    AsciiPixel.colormode[] = old_colormode
end
