module ImageInTerminal

using ColorTypes
using Images
using Crayons

export

    rgb2ansi,
    imshow,
    imshow256,
    imshow24bit,

    @imshow24bit_on_show

abstract TermColorDepth
immutable TermColor256   <: TermColorDepth end
immutable TermColor24bit <: TermColorDepth end

"""
    rgb2ansii(color::Colorant) -> Int

Converts the given colorant into a integer index corresponding to
the 256r-colors ANSI code that most terminals support.

```julia
julia> rgb2ansi(RGB(1., 1., 0.))
226
```

This function also tries to make good use of the extended number
of available shades of gray (ansi codes 232 to 255).

```julia
julia> rgb2ansi(RGB(.5, .5, .5))
244

julia> rgb2ansi(Gray(.5))
244
```
"""
rgb2ansi(color) = rgb2ansi(color, TermColor256())

function rgb2ansi(col::AbstractRGB, ::TermColor256)
    r, g, b = red(col), green(col), blue(col)
    r24 = round(Int, r * 23)
    g24 = round(Int, g * 23)
    b24 = round(Int, b * 23)
    if r24 == g24 == b24
        # Use grayscales because of higher resultion
        # This way even grayscale RGB images look good.
        232 + r24
    else
        r6 = round(Int, r * 5)
        g6 = round(Int, g * 5)
        b6 = round(Int, b * 5)
        16 + 36 * r6 + 6 * g6 + b6
    end
end

function rgb2ansi{T}(gr::Color{T,1}, ::TermColor256)
    round(Int, 232 + real(gr) * 23)
end

# 24 bit colors
function rgb2ansi(col::AbstractRGB, ::TermColor24bit)
    r, g, b = red(col), green(col), blue(col)
    round(Int, r * 255), round(Int, g * 255), round(Int, b * 255)
end

function rgb2ansi{T}(gr::Color{T,1}, ::TermColor24bit)
    r = round(Int, real(gr) * 255)
    r, r, r
end

# Fallback for non-rgb and transparent colors (convert to rgb)
rgb2ansi(gr::Color, colordepth::TermColorDepth) = rgb2ansi(convert(RGB, gr), colordepth)
rgb2ansi(gr::TransparentColor, colordepth::TermColorDepth) = rgb2ansi(color(gr), colordepth)

# -----------------------------------------------------------

abstract ImageEncoder
immutable BigBlocks   <: ImageEncoder end
immutable SmallBlocks <: ImageEncoder end

"""
    encodeimg(enc::ImageEncoder, img, [maxheight], [maxwidth])

Transforms the pixel of the given image `img`, which has to be an
array of `Colorant`, into a string of unicode characters using
ansi terminal colors.

- The encoder `enc` specifies which kind of unicode represenation
  should be used.

- `maxheight` and `maxwidth` specify the maximum numbers of
  string characters that should be used for the resulting image.
  Larger images are downscaled automatically using `restrict`.

The function returns a tuple with three elements:

1. A vector of strings containing the encoded image.
   Each element represent one line. The lines do not contain
   newline characters.

2. Number of lines in the vector.

3. Number of visible characters per line (others are colorcodes).
"""
function encodeimg{C<:Colorant}(
        ::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{C},
        maxheight::Int = 50,
        maxwidth::Int = 150)
    while ceil(size(img,1)/2) > maxheight || size(img,2) > maxwidth
        img = restrict(img)
    end
    h, w = size(img)
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for y in 1:2:h
        for x in 1:w
            fgcol = rgb2ansi(img[y,x], colordepth)
            bgcol = y+1 <= h ? rgb2ansi(img[y+1,x], colordepth) : Symbol("nothing")
            print(io, Crayon(foreground=fgcol, background=bgcol), "▀")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""]), length(1:2:h), w
end

function encodeimg{C<:Colorant}(
        ::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{C},
        maxheight::Int = 50,
        maxwidth::Int = 150)
    while size(img,1) > maxheight || size(img,2)*2 > maxwidth
        img = restrict(img)
    end
    h, w = size(img)
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for y in 1:h
        for x in 1:w
            fgcol = rgb2ansi(img[y,x], colordepth)
            print(io, Crayon(foreground=fgcol), "██")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""]), h, 2*w
end

"""
    imshow([stream], img, [depth::TermColorDepth])

Displays the given image `img` using unicode characters and
terminal colors (defaults to 256 colors).
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
function imshow{C<:Colorant}(io::IO, img::AbstractMatrix{C}, colordepth::TermColorDepth)
    io_h, io_w = isinteractive() ? displaysize(io) : (100, 100)
    img_h, img_w = size(img)
    str = if img_h <= io_h-4 && img_w*2 <= io_w
        first(encodeimg(BigBlocks(), colordepth, img, io_h-4, io_w))
    else
        first(encodeimg(SmallBlocks(), colordepth, img, io_h-4, io_w))
    end
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

imshow(img) = imshow(STDOUT, img, TermColor256())

"""
    imshow256([stream], img)

Displays the given image `img` using unicode characters and
the widely supported 256 terminal colors.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
imshow256(io, img) = imshow(io, img, TermColor256())
imshow256(img) = imshow256(STDOUT, img)

"""
    imshow256([stream], img)

Displays the given image `img` using unicode characters and
the 24 terminal colors that some modern terminals support.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
imshow24bit(io, img) = imshow(io, img, TermColor24bit())
imshow24bit(img) = imshow24bit(STDOUT, img)

"""
    @imshow24bit_on_show()

Triggers `imshow24bit` automatically if an array of colorants is to
be displayed in the julia REPL.
"""
macro imshow24bit_on_show()
    esc(quote
        info("Overwriting Base.show for AbstractArray{T<:Colorant} with imshow24bit. If images now render as non-sense for you, then that means your terminal does not support 24 bit colors. To return to the default behaviour of using imshow256 you need to restart the Julia session.")
        function Base.show{C<:ColorTypes.Colorant}(io::IO, ::MIME"text/plain", img::AbstractMatrix{C})
            println(summary(img), ":")
            ImageInTerminal.imshow24bit(io, img)
        end
    end)
end

function Base.show{C<:ColorTypes.Colorant}(io::IO, ::MIME"text/plain", img::AbstractMatrix{C})
    println(summary(img), ":")
    ImageInTerminal.imshow256(io, img)
end

end # module

