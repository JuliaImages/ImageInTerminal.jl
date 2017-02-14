"""
    imshow([stream], img, [depth::TermColorDepth])

Displays the given image `img` using unicode characters and
terminal colors (defaults to 256 colors).
`img` has to be an array of `Colorant`.

If working in the REPL, the function tries to choose the encoding
based on the current display size. The image will also be
downsampled to fit into the display (using `restrict`).
"""
function imshow{C<:Colorant}(
        io::IO,
        img::AbstractMatrix{C},
        colordepth::TermColorDepth)
    io_h, io_w = isinteractive() ? displaysize(io) : (50, 80)
    img_h, img_w = size(img)
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
function imshow{C<:Colorant}(
        io::IO,
        img::AbstractVector{C},
        colordepth::TermColorDepth)
    io_h, io_w = isinteractive() ? displaysize(io) : (1, 80)
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

