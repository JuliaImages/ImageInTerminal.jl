module ImageInTerminal

using Crayons
using ColorTypes
using ImageCore
using ImageTransformations

export

    colorant2ansi,
    imshow,
    imshow256,
    imshow24bit

include("colorant2ansi.jl")
include("encodeimg.jl")
include("imshow.jl")

# -------------------------------------------------------------------
# overload default show in the REPL for colorant (arrays)

const colormode = TermColorDepth[TermColor256()]

"""
    use_256()

Triggers `imshow256` automatically if an array of colorants is to
be displayed in the julia REPL. (This is the default)
"""
use_256() = (colormode[1] = TermColor256())

"""
    use_24bit()

Triggers `imshow24bit` automatically if an array of colorants is to
be displayed in the julia REPL.
Call `ImageInTerminal.use_256()` to restore default behaviour.
"""
use_24bit() = (colormode[1] = TermColor24bit())

# colorant arrays
function Base.show(
        io::IO, ::MIME"text/plain",
        img::AbstractVecOrMat{<:Colorant})
    println(io, summary(img), ":")
    ImageInTerminal.imshow(io, img, colormode[1])
end

# colorant
function Base.show(io::IO, ::MIME"text/plain", color::Colorant)
    fgcol = _colorant2ansi(color, colormode[1])
    chr = _charof(alpha(color))
    print(io, Crayon(foreground = fgcol), chr, chr, " ")
    print(io, Crayon(foreground = :white), color)
    print(io, Crayon(reset = true))
end

end # module

