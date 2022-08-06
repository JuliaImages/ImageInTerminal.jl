module ImageInTerminal

using AsciiPixel
using ImageCore
using ColorTypes
using Crayons
using FileIO

import ImageBase: restrict
import Sixel

# -------------------------------------------------------------------
# overload default show in the REPL for colorant (arrays)

const encoder_backend = Ref(:ImageInTerminal)
const should_render_image = Ref(true)
const small_imgs_sixel = Ref(false)

"""
    disable_encoding()

Disable the image encoding feature and show images as if they are normal arrays.

This can be restored by calling `ImageInTerminal.enable_encoding()`.
"""
disable_encoding() = (should_render_image[] = false)

"""
    enable_encoding()

Enable the image encoding feature and show images in terminal.

This can be disabled by calling `ImageInTerminal.disable_encoding()`. To choose between
different encoding method, call `AsciiPixel.set_colormode(8)` or `AsciiPixel.set_colormode(24)`.
"""
enable_encoding() = (should_render_image[] = true)

"""
    choose_sixel(img::AbstractArray)

Choose to encode the image using sixels based on the size of the encoded image.
"""
function choose_sixel(img::AbstractArray)
    encoder_backend[] == :Sixel || return false

    # Sixel requires at least 6 pixels in row direction and thus doesn't perform very well for vectors.
    # ImageInTerminal encoder is good enough for vector case.
    ndims(img) == 1 && return false

    if small_imgs_sixel[]
        return true
    else
        # Small images really do not need sixel encoding.
        # `60` is a randomly chosen value (10 sixel); it's not the best because
        # 60x60 image will be very small in terminal after sixel encoding.
        any(size(img) .<= 12) && return false
        all(size(img) .<= 60) && return false
        return true
    end
end

# colorant arrays
function Base.show(io::IO, mime::MIME"text/plain", img::AbstractArray{<:Colorant})
    if should_render_image[]
        println(io, summary(img), ":")
        imshow(io, img)
    else
        invoke(Base.show, Tuple{typeof(io),typeof(mime),AbstractArray}, io, mime, img)
    end
end

# colorant
function Base.show(io::IO, mime::MIME"text/plain", color::Colorant)
    if should_render_image[]
        fgcol = AsciiPixel._colorant2ansi(color, AsciiPixel.colormode[])
        chr = AsciiPixel._charof(alpha(color))
        print(io, Crayon(; foreground=fgcol), chr, chr, " ")
        print(io, Crayon(; foreground=:white), color)
        print(io, Crayon(; reset=true))
    else
        invoke(Base.show, Tuple{typeof(io),typeof(mime),Any}, io, mime, color)
    end
end

include("display.jl")

"""
    imshow([stream], img, [maxsize])

Displays the given image `img` using unicode characters and
terminal colors (defaults to 256 colors).
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display.

Supported encoding:
    - sixel (`Sixel` backend)
    - ascii (`AsciiPixel` backend)
"""

function imshow(io::IO, img::AbstractArray{<:Colorant}, maxsize::Tuple=displaysize(io))
    if choose_sixel(img)
        sixel_encode(io, img)
    else
        colormode = AsciiPixel.colormode[]
        if ndims(img) > 2
            Base.show_nd(io, img, (io, x) -> ascii_display(io, x, colormode, maxsize), true)
        else
            ascii_display(io, img, colormode, maxsize)
        end
    end
end

imshow(img::AbstractArray{<:Colorant}, args...) = imshow(stdout, img, args...)
imshow(img, args...) =
    throw(ArgumentError("imshow only supports colorant arrays with 1 or 2 dimensions"))

sixel_encode(args...; kwargs...) = Sixel.sixel_encode(args...; kwargs...)

function __init__()
    enable_encoding()

    Sixel.is_sixel_supported() && (encoder_backend[] = :Sixel)

    pushdisplay(TerminalGraphicDisplay(stdout, devnull))
end

end
