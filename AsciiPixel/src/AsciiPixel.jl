module AsciiPixel

using ImageBase: restrict
using ImageCore
using Crayons

export TermColorDepth, TermColor256, TermColor24bit, ascii_encode

include("colorant2ansi.jl")
include("ascii_encode.jl")

end # module
