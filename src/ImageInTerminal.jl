module ImageInTerminal

using ColorTypes
using Images
using Crayons

export

    rgb2ansi,
    imshow

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
function rgb2ansi{T}(col::Colorant{T,3})
    r, g, b = red(col), green(col), blue(col)
    r24 = round(Int, r*23)
    g24 = round(Int, g*23)
    b24 = round(Int, b*23)
    if r24 == g24 == b24
        # Use grayscales because of higher resultion
        # This way even grayscale RGB images look good.
        232 + r24
    else
        r6 = round(Int, r*5)
        g6 = round(Int, g*5)
        b6 = round(Int, b*5)
        16 + 36 * r6 + 6 * g6 + b6
    end
end

rgb2ansi{T}(gr::Colorant{T,1}) = round(Int, 232 + real(gr) * 23)
rgb2ansi{T}(gr::Colorant{T}) = rgb2ansi(color(gr))

abstract ImageEncoder
immutable BigBlocks <: ImageEncoder end
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
        img::AbstractMatrix{C},
        maxheight::Int = 100,
        maxwidth::Int = 100)
    while ceil(size(img,1)/2) > maxheight || size(img,2) > maxwidth
        img = restrict(img)
    end
    h, w = size(img)
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for y in 1:2:h
        for x in 1:w
            fgcol = rgb2ansi(img[y,x])
            bgcol = y+1 <= h ? rgb2ansi(img[y+1,x]) : Symbol("nothing")
            print(io, Crayon(foreground=fgcol, background=bgcol), "▀")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""]), length(1:2:h), w
end

function encodeimg{C<:Colorant}(
        ::BigBlocks,
        img::AbstractMatrix{C},
        maxheight::Int = 50,
        maxwidth::Int = 50)
    while size(img,1) > maxheight || size(img,2)*2 > maxwidth
        img = restrict(img)
    end
    h, w = size(img)
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for y in 1:h
        for x in 1:w
            fgcol = rgb2ansi(img[y,x])
            print(io, Crayon(foreground=fgcol), "██")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""]), h, 2*w
end

"""
    imshow([stream], img)

Displays the given image `img` using unicode characters and
terminal colors. `img` has to be an array or `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
function imshow{C<:Colorant}(io::IO, img::AbstractMatrix{C})
    io_h, io_w = isinteractive() ? displaysize(io) : (100, 100)
    img_h, img_w = size(img)
    str = if img_h <= io_h-4 && img_w*2 <= io_w-1
        encodeimg(BigBlocks(), img, io_h-4, io_w-1)[1]
    else
        encodeimg(SmallBlocks(), img, io_h-4, io_w-1)[1]
    end
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

imshow(img) = imshow(STDOUT, img)

# Overwrite how colorant arrays are displayed
function Base.show{C<:Colorant}(io::IO, ::MIME"text/plain", img::AbstractMatrix{C})
    println(summary(img), ":")
    imshow(io, img)
end

end # module

