module ImageInTerminal

using XTermColors
using ImageCore
using ColorTypes
using Crayons
using FileIO

import XTermColors: TermColorDepth, TermColor8bit, TermColor24bit
import ImageBase: restrict
import Sixel

# -------------------------------------------------------------------
# overload default show in the REPL for colorant (arrays)

const COLORMODE = Ref{TermColorDepth}(TermColor8bit())
const ENCODER_BACKEND = Ref(:XTermColors)
const SHOULD_RENDER_IMAGE = Ref(true)
const SMALL_IMGS_SIXEL = Ref(false)
const RESET = Crayon(; reset=true)
const SUMMARY = Ref(false)

"""
    disable_encoding()

Disable the image encoding feature and show images as if they are normal arrays.

This can be restored by calling `ImageInTerminal.enable_encoding()`.
"""
disable_encoding() = SHOULD_RENDER_IMAGE[] = false

"""
    enable_encoding()

Enable the image encoding feature and show images in terminal.

This can be disabled by calling `ImageInTerminal.disable_encoding()`. To choose between
different encoding method, call `ImageInTerminal.set_colormode(8)` or `ImageInTerminal.set_colormode(24)`.
"""
enable_encoding() = SHOULD_RENDER_IMAGE[] = true

"""
    choose_sixel(img::AbstractArray)

Choose to encode the image using sixels based on the size of the encoded image.
"""
function choose_sixel(img::AbstractArray)
    ENCODER_BACKEND[] === :Sixel || return false

    # Sixel requires at least 6 pixels in row direction and thus doesn't perform very well for vectors.
    # ImageInTerminal encoder is good enough for vector case.
    ndims(img) == 1 && return false

    if SMALL_IMGS_SIXEL[]
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
    if SHOULD_RENDER_IMAGE[]
        SUMMARY[] && println(io, summary(img), ":")
        imshow(io, img)
    else
        invoke(Base.show, Tuple{typeof(io),typeof(mime),AbstractArray}, io, mime, img)
    end
end

# colorant
function Base.show(io::IO, mime::MIME"text/plain", color::Colorant)
    if SHOULD_RENDER_IMAGE[]
        fgcol = XTermColors._colorant2ansi(color, COLORMODE[])
        chr = XTermColors._charof(alpha(color))
        XTermColors._printc(
            io,
            Crayon(; foreground=fgcol),
            chr,
            chr,
            ' ',
            Crayon(; foreground=:white),
            color,
            RESET
        )
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
    - ascii (`XTermColors` backend)
"""

function imshow(io::IO, img::AbstractArray{<:Colorant}, maxsize::Tuple=displaysize(io))
    buf = PipeBuffer()
    io_color = get(io, :color, false)
    iobuf = IOContext(buf, :color => io_color)
    if choose_sixel(img)
        sixel_encode(iobuf, img)
    else
        if ndims(img) > 2
            Base.show_nd(
                iobuf,
                img,
                (iobuf, x) -> ascii_display(iobuf, x, COLORMODE[], maxsize),
                true
            )
        else
            ascii_display(iobuf, img, COLORMODE[], maxsize)
        end
    end
    write(io, read(iobuf, String))
end

imshow(img::AbstractArray{<:Colorant}, args...) = imshow(stdout, img, args...)
imshow(img, args...) =
    throw(ArgumentError("imshow only supports colorant arrays with 1 or 2 dimensions"))

sixel_encode(args...; kwargs...) = Sixel.sixel_encode(args...; kwargs...)

"""
    set_colormode(bit::Int)

Sets the terminal color depth to the given argument.
"""
function set_colormode(bit::Int)
    if bit == 8
        COLORMODE[] = TermColor8bit()
    elseif bit == 24
        COLORMODE[] = TermColor24bit()
    else
        error("Setting color depth to $bit-bit is not supported, valid modes are:
          - 8bit (256 colors)
          - 24bit")
    end
    COLORMODE[]
end

is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

function __init__()
    enable_encoding()

    # use 24bit if the terminal supports it
    is_24bit_supported() && set_colormode(24)

    Sixel.is_sixel_supported() && (ENCODER_BACKEND[] = :Sixel)

    pushdisplay(TerminalGraphicDisplay(stdout))
end

end
