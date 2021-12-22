abstract type ImageEncoder end
struct BigBlocks   <: ImageEncoder end
struct SmallBlocks <: ImageEncoder end

const alpha_chars = ('⋅', '░', '▒', '▓', '█')
function _charof(alpha)
    idx = round(Int, alpha * (length(alpha_chars)-1))
    alpha_chars[clamp(idx + 1, 1, length(alpha_chars))]
end

"""
    ascii_encode(enc::ImageEncoder, colordepth::TermColorDepth, img, [maxheight], [maxwidth])

Transforms the pixel of the given image `img`, which has to be an
array of `Colorant`, into a string of unicode characters using
ansi terminal colors.

- The encoder `enc` specifies which kind of unicode represenation
  should be used.

- The `colordepth` can either be `TermColor8bit()` or `TermColor24bit()`
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

function ascii_encode(
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
    io = PipeBuffer()
    for y in first(yinds):2:last(yinds)
        print(io, Crayon(reset = true))
        for x in xinds
            fgcol = _colorant2ansi(img[y,x], colordepth)
            bgcol = if y+1 <= last(yinds)
                _colorant2ansi(img[y+1,x], colordepth)
            else
                # if reached it means that the last character row
                # has only the upper pixel defined.
                nothing
            end
            print(io, Crayon(foreground=fgcol, background=bgcol), "▀")
        end
        println(io, Crayon(reset = true))
    end
    replace.(readlines(io), Ref("\n" => ""))::Vector{String}, length(1:2:h), w
end

function ascii_encode(
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
    io = PipeBuffer()
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
    replace.(readlines(io), Ref("\n" => ""))::Vector{String}, h, 2w
end

function ascii_encode(
        ::SmallBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{<:Colorant},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    while size(img, 1) > maxwidth
        img = restrict(img)
    end
    io = PipeBuffer()
    print(io, Crayon(reset = true))
    for i in axes(img, 1)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        print(io, Crayon(foreground = fgcol), chr)
    end
    println(io, Crayon(reset = true))
    replace.(readlines(io), Ref("\n" => ""))::Vector{String}, 1, size(img, 1)
end

function ascii_encode(
        ::BigBlocks,
        colordepth::TermColorDepth,
        img::AbstractVector{<:Colorant},
        maxwidth::Int = 80)
    maxwidth  = max(maxwidth, 5)
    inds = axes(img, 1)
    w = length(inds)
    n = 3w > maxwidth ? floor(Int,maxwidth/6) : w
    io = PipeBuffer()
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
    replace.(readlines(io), Ref("\n" => ""))::Vector{String}, 1, n < w ? 3(length(1:n) + 1 + length(w-n+1:w)) : 3w
end


"""
    ascii_encode([stream], img, [depth::TermColorDepth], [maxsize])

Displays the given image `img` using unicode characters and terminal colors.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""

# colorant matrix
function ascii_encode(
        io::IO,
        img::AbstractMatrix{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    io_h, io_w = maxsize
    img_h, img_w = map(length, axes(img))
    enc = img_h <= io_h - 4 && 2img_w <= io_w ? BigBlocks : SmallBlocks
    str = first(ascii_encode(enc(), colordepth, img, io_h - 4, io_w))
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

# colorant vector
function ascii_encode(
        io::IO,
        img::AbstractVector{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    io_h, io_w = maxsize
    img_w = length(img)
    enc = 3img_w <= io_w ? BigBlocks : SmallBlocks
    str = first(ascii_encode(enc(), colordepth, img, io_w))
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

ascii_encode(io::IO, img::AbstractArray{<:Colorant}) = ascii_encode(io, img, colormode[])
