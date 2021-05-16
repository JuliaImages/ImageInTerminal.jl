function use_sixel(img::AbstractArray)
    encoder_backend[1] == :Sixel || return false

    # Sixel requires at least 6 pixels in row direction and thus doesn't perform very well for vectors.
    # ImageInTerminal encoder is good enough for vector case.
    ndims(img) == 1 && return false

    # Small images really do not need sixel encoding.
    # `100` is a randomly chosen value; it's not the best because
    # 100×100 image will be very small in terminal after sixel encoding.
    any(size(img) .<= 12) && return false
    all(size(img) .<= 100) && return false
    return true
end

"""
    imshow([stream], img, [depth::TermColorDepth], [maxsize])

Displays the given image `img` using unicode characters and
terminal colors (defaults to 256 colors).
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
function imshow(
        io::IO,
        img::AbstractArray{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    use_sixel(img) && return sixel_encode(io, img)

    # otherwise, use our own implementation
    print_matrix(io, x) = imshow(io, x, colordepth, maxsize)
    Base.show_nd(io, img, print_matrix, true)
end

function imshow(
        io::IO,
        img::AbstractMatrix{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    use_sixel(img) && return sixel_encode(io, img)

    # otherwise, use our own implementation
    io_h, io_w = maxsize
    img_h, img_w = map(length, axes(img))
    str = if img_h <= io_h-4 && 2img_w <= io_w
        first(encodeimg(BigBlocks(),   colordepth, img, io_h-4, io_w))
    else
        first(encodeimg(SmallBlocks(), colordepth, img, io_h-4, io_w))
    end
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

# colorant vector
function imshow(
        io::IO,
        img::AbstractVector{<:Colorant},
        colordepth::TermColorDepth,
        maxsize::Tuple = displaysize(io))
    @assert !use_sixel(img) "Sixel should be disabled for Vector colorant"

    io_h, io_w = maxsize
    img_w = length(img)
    str = if 3img_w <= io_w
        first(encodeimg(BigBlocks(),   colordepth, img, io_w))
    else
        first(encodeimg(SmallBlocks(), colordepth, img, io_w))
    end
    for (idx, line) in enumerate(str)
        print(io, line)
        idx < length(str) && println(io)
    end
end

imshow(io::IO, img, args...) = imshow(io, img, colormode[1], args...)
imshow(img, args...) = imshow(stdout, img, colormode[1], args...)
imshow(io::IO, img, colordepth::TermColorDepth, args...) = throw(ArgumentError("imshow only supports colorant arrays with 1 or 2 dimensions"))

"""
    imshow256([stream], img, [maxsize])

Displays the given image `img` using unicode characters and
the widely supported 256 terminal colors.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
imshow256(io::IO, img, args...) = imshow(io, img, TermColor256(), args...)
imshow256(img, args...) = imshow256(stdout, img, args...)

"""
    imshow24bit([stream], img, [maxsize])

Displays the given image `img` using unicode characters and
the 24 terminal colors that some modern terminals support.
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
imshow24bit(io::IO, img, args...) = imshow(io, img, TermColor24bit(), args...)
imshow24bit(img, args...) = imshow24bit(stdout, img, args...)
