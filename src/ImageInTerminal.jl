module ImageInTerminal

using Requires
using Crayons
using ImageCore
using ImageBase: restrict
using AsciiPixel
using Reexport

export
    imshow,
    imshow256,
    imshow24bit

@reexport using AsciiPixel: TermColor256, TermColor24bit
using AsciiPixel: TermColorDepth

include("encodeimg.jl")
include("imshow.jl")
include("deprecations.jl")

# -------------------------------------------------------------------
# overload default show in the REPL for colorant (arrays)

const colormode = TermColorDepth[TermColor256()]
const should_render_image = Bool[true]
const encoder_backend = [:ImageInTerminal]

"""
    use_256()

Triggers `imshow256` automatically if an array of colorants is to
be displayed in the julia REPL. (This is the default)
"""
use_256() = (colormode[1] = TermColor256(); should_render_image[1] = true)

"""
    use_24bit()

Triggers `imshow24bit` automatically if an array of colorants is to
be displayed in the julia REPL.
Call `ImageInTerminal.use_256()` to restore default behaviour.
"""
use_24bit() = (colormode[1] = TermColor24bit(); should_render_image[1] = true)

"""
    disable_encoding()

Disable the image encoding feature and show images as if they are normal arrays.

This can be restored by calling `ImageInTerminal.enable_encoding()`.
"""
disable_encoding() = (should_render_image[1] = false)

"""
    enable_encoding()

Enable the image encoding feature and show images in terminal.

This can be disabled by calling `ImageInTerminal.disable_encoding()`. To choose between
different encoding method, call `ImageInTerminal.use_256()` or `ImageInTerminal.use_24bit()`.
"""
enable_encoding() = (should_render_image[1] = true)


# colorant arrays
function Base.show(
        io::IO, mime::MIME"text/plain",
        img::AbstractArray{<:Colorant})
    if should_render_image[1]
        println(io, summary(img), ":")
        ImageInTerminal.imshow(io, img, colormode[1])
    else
        invoke(Base.show, Tuple{typeof(io), typeof(mime), AbstractArray}, io, mime, img)
    end
end

# colorant
function Base.show(io::IO, mime::MIME"text/plain", color::Colorant)
    if should_render_image[1]
        fgcol = colormode[1](color)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr, chr, " ")
        print(io, Crayon(foreground = :white), color)
        print(io, Crayon(reset = true))
    else
        invoke(Base.show, Tuple{typeof(io), typeof(mime), Any}, io, mime, color)
    end
end

function __init__()
    # use 24bit if the terminal supports it
    lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor") && use_24bit()
    enable_encoding()

    if VERSION < v"1.6.0-DEV.888" && Sys.iswindows()
        # https://discourse.julialang.org/t/image-in-repl-does-not-correct/46359
        @warn "ImageInTerminal is not supported for Windows platform: Julia at least v1.6.0 is required."
        disable_encoding()
    end

    # Sixel requires Julia at least v1.6. We don't want to maintain an ImageInTerminal branch
    # for old Julia versions so here we use Requires to conditionally load Sixel as an advanced
    # image encoding choice. All ImageInTerminal functionality is still there even without Sixel
    # -- well, basically.
    @require Sixel="45858cf5-a6b0-47a3-bbea-62219f50df47" begin
        if Sixel.is_sixel_supported()
            encoder_backend[1] = :Sixel
        end
        sixel_encode(args...; kwargs...) = Sixel.sixel_encode(args...; kwargs...)
    end
end

end # module
