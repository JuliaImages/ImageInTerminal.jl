# not exported
abstract ImageEncoder
immutable BigBlocks   <: ImageEncoder end
immutable SmallBlocks <: ImageEncoder end

const alpha_chars = ('⋅', '░', '▒', '▓', '█')
function _charof(alpha)
    idx = round(Int, alpha * (length(alpha_chars)-1))
    alpha_chars[clamp(idx + 1, 1, length(alpha_chars))]
end

"""
    encodeimg(enc::ImageEncoder, colordepth::TermColorDepth, img, [maxheight], [maxwidth])

Transforms the pixel of the given image `img`, which has to be an
array of `Colorant`, into a string of unicode characters using
ansi terminal colors.

- The encoder `enc` specifies which kind of unicode represenation
  should be used.

- The `colordepth` can either be `TermColor256()` or `TermColor24bit()`
  and specifies which terminal color codes should be used.

- `maxheight` and `maxwidth` specify the maximum numbers of
  string characters that should be used for the resulting image.
  Larger images are downscaled automatically using `restrict`.

The function returns a tuple with three elements:

1. A vector of strings containing the encoded image.
   Each element represent one line. The lines do not contain
   newline characters.

2. Number of lines in the vector.

3. Number of visible characters per line (the remaining are colorcodes).
"""
function encodeimg{C<:Colorant}(
        ::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{C},
        maxheight::Int = 50,
        maxwidth::Int = 80)
    maxheight = max(maxheight, 5)
    maxwidth  = max(maxwidth,  5)
    h, w = size(img)
    while ceil(h/2) > maxheight || w > maxwidth
        img = restrict(img)
        h, w = size(img)
    end
    io = IOBuffer()
    for y in 1:2:h
        print(io, Crayon(reset = true))
        for x in 1:w
            fgcol = _colorant2ansi(img[y,x], colordepth)
            bgcol = if y+1 <= h
                _colorant2ansi(img[y+1,x], colordepth)
            else
                # if reached it means that the last character row
                # has only the upper pixel defined.
                Symbol("nothing")
            end
            print(io, Crayon(foreground=fgcol, background=bgcol), "▀")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""])::Vector{String}, length(1:2:h), w
end

function encodeimg{C<:Colorant}(
        ::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{C},
        maxheight::Int = 50,
        maxwidth::Int = 80)
    maxheight = max(maxheight, 5)
    maxwidth  = max(maxwidth,  5)
    h, w = size(img)
    while h > maxheight || 2w > maxwidth
        img = restrict(img)
        h, w = size(img)
    end
    io = IOBuffer()
    for y in 1:h
        print(io, Crayon(reset = true))
        for x in 1:w
            color = img[y,x]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            print(io, Crayon(foreground = fgcol), chr, chr)
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), ["\n"], [""])::Vector{String}, h, 2w
end

# colorant vector
function encodeimg{C<:Colorant}(
        enc::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{C},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    w = length(img)
    if w > maxwidth
        img = imresize(img, maxwidth)
        w = length(img)
    end
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for i in 1:w
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr)
    end
    println(io, Crayon(reset = true))
    replace.(readlines(seek(io,0)), ["\n"], [""])::Vector{String}, 1, w
end

function encodeimg{C<:Colorant}(
        enc::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{C},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    w = length(img)
    n = 3w > maxwidth ? floor(Int,maxwidth/6) : w
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for i in 1:n
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr, chr, " ")
    end
    if n < w
        print(io, Crayon(reset = true), " … ")
        for i in w-n+1:w
            color = img[i]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            print(io, Crayon(foreground = fgcol), chr, chr, " ")
        end
    end
    println(io, Crayon(reset = true))
    replace.(readlines(seek(io,0)), ["\n"], [""])::Vector{String}, 1, n < w ? 3*(length(1:n) + 1 + length(w-n+1:w)) : 3w
end

