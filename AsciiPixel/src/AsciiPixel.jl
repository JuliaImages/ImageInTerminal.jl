module AsciiPixel

using ImageBase: restrict
using ImageCore
using Crayons

export ascii_display

include("colorant2ansi.jl")
include("ascii_encode.jl")

const colormode = Ref{TermColorDepth}(TermColor8bit())

"""
    set_colordepth(bit::Int)

Sets the terminal color depth to the given argument.
"""
function set_colordepth(bit::Int)
    if bit == 8
        colormode[] = TermColor8bit()
    elseif bit == 24
        colormode[] = TermColor24bit()
    else
        error("Setting color depth to $bit-bit is not supported, valid modes are:
          - 8bit (256 colors)
          - 24bit")
    end
    colormode[]
end

"""
    ascii_display([stream], img, [depth::TermColorDepth], [maxsize])

Displays the given image `img` using unicode characters and terminal colors.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""

# colorant matrix
function ascii_display(
        io::IO,
        img::AbstractMatrix{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    io_h, io_w = maxsize
    img_h, img_w = map(length, axes(img))
    enc = img_h <= io_h - 4 && 2img_w <= io_w ? BigBlocks() : SmallBlocks()
    # @sync for row in img_rows
    #     buffer = ascii_encode(enc, colordepth, img[row, :], io_w)
    #     @async print(io, buffer)
    # end
    str, = ascii_encode(enc, colordepth, img, io_h - 4, io_w)
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

# colorant vector
function ascii_display(
        io::IO,
        img::AbstractVector{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    io_h, io_w = maxsize
    img_w = length(img)
    enc = 3img_w <= io_w ? BigBlocks() : SmallBlocks()
    str, = ascii_encode(enc, colordepth, img, io_w)
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

ascii_display(io::IO, img::AbstractArray{<:Colorant}) = ascii_display(io, img, colormode[])

is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

function __init__()
    # use 24bit if the terminal supports it
    is_24bit_supported() && set_colordepth(24)
end

end # module
