module AsciiPixel

using ImageBase: restrict
using ImageCore
using Crayons

export ascii_encode

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
        error("Setting color depth to $bit-bit is not supported, valid mode are:
          - 8bit (256 colors)
          - 24bit")
    end
    colormode[]
end

set_colordepth(bit::AbstractString) = set_colordepth(parse(Int, replace(bit, r"[^0-9]"=>"")))

function __init__()
    # use 24bit if the terminal supports it
    lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor") && set_colordepth(24)
end

end # module
