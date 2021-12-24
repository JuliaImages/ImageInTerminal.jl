function imshow256(args...; kwargs...)
    Base.depwarn(
        "`imshow256(x)` is deprecated, use `AsciiPixel.set_colormode(8)` followed by `imshow(x)`",
        :imshow256
    )
    old_colormode = AsciiPixel.colormode[]
    AsciiPixel.set_colormode(8)
    imshow(args...; kwargs...)
    AsciiPixel.colormode[] = old_colormode
end

function imshow24bit(args...; kwargs...)
    Base.depwarn(
        "`imshow24bit(x)` is deprecated, use `AsciiPixel.set_colormode(24)` followed by `imshow(x)`",
        :imshow24bit
    )
    old_colormode = AsciiPixel.colormode[]
    AsciiPixel.set_colormode(24)
    imshow(args...; kwargs...)
    AsciiPixel.colormode[] = old_colormode
end
