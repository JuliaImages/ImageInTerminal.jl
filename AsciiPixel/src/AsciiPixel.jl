module AsciiPixel

using ImageBase: restrict
using ImageCore
using Crayons

export ascii_encode

include("colorant2ansi.jl")
include("ascii_encode.jl")

const colormode = Ref{TermColorDepth}(TermColor256())

"""
    use_256()

Triggers `ascii_encode256` (256 colors, 8bit) automatically if an array of colorants is to
be displayed in the julia REPL. (This is the default)
"""
use_256() = (colormode[] = TermColor256())

"""
    use_24bit()

Triggers `ascii_encode24bit` automatically if an array of colorants is to
be displayed in the julia REPL.
Call `AsciiPixel.use_256()` to restore default behaviour.
"""
use_24bit() = (colormode[] = TermColor24bit())

end # module
