# not exported
abstract type ImageEncoder end
struct BigBlocks   <: ImageEncoder end
struct SmallBlocks <: ImageEncoder end

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
function encodeimg(
        ::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{<:Colorant},
        maxheight::Int = 50,
        maxwidth::Int = 80)
    maxheight = max(maxheight, 5)
    maxwidth  = max(maxwidth,  5)
    h, w = map(length, axes(img))
    while ceil(h/2) > maxheight || w > maxwidth
        img = restrict(img)
        h, w = map(length, axes(img))
    end
    yinds, xinds = axes(img)
    io = IOBuffer()
    for y in first(yinds):2:last(yinds)
        print(io, Crayon(reset = true))
        for x in xinds
            fgcol = _colorant2ansi(img[y,x], colordepth)
            bgcol = if y+1 <= last(yinds)
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
    replace.(readlines(seek(io,0)), Ref("\n" => ""))::Vector{String}, length(1:2:h), w
end

function encodeimg(
        ::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractMatrix{<:Colorant},
        maxheight::Int = 50,
        maxwidth::Int = 80)
    maxheight = max(maxheight, 5)
    maxwidth  = max(maxwidth,  5)
    h, w = map(length, axes(img))
    while h > maxheight || 2w > maxwidth
        img = restrict(img)
        h, w = map(length, axes(img))
    end
    yinds, xinds = axes(img)
    io = IOBuffer()
    for y in yinds
        print(io, Crayon(reset = true))
        for x in xinds
            color = img[y,x]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            print(io, Crayon(foreground = fgcol), chr, chr)
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(seek(io,0)), Ref("\n" => ""))::Vector{String}, h, 2w
end

# colorant vector
function encodeimg(
        enc::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{<:Colorant},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    w = length(axes(img, 1))
    if w > maxwidth
        img = imresize(img, maxwidth)
        w = length(axes(img, 1))
    end
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for i in axes(img, 1)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr)
    end
    println(io, Crayon(reset = true))
    replace.(readlines(seek(io,0)), Ref("\n" => ""))::Vector{String}, 1, w
end

function encodeimg(
        enc::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{<:Colorant},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    inds = axes(img, 1)
    w = length(inds)
    n = 3w > maxwidth ? floor(Int,maxwidth/6) : w
    io = IOBuffer()
    print(io, Crayon(reset = true))
    for i in (0:n-1) .+ first(inds)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr, chr, " ")
    end
    if n < w
        print(io, Crayon(reset = true), " … ")
        for i in last(inds)-n+1:last(inds)
            color = img[i]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            print(io, Crayon(foreground = fgcol), chr, chr, " ")
        end
    end
    println(io, Crayon(reset = true))
    replace.(readlines(seek(io,0)), Ref("\n" => ""))::Vector{String}, 1, n < w ? 3*(length(1:n) + 1 + length(w-n+1:w)) : 3w
end
