struct TerminalGraphicDisplay{TC<:IO,TS<:IO} <: AbstractDisplay
    content_stream::TC
    summary_stream::TS
end
TerminalGraphicDisplay(io::IO) = TerminalGraphicDisplay(io, io)

Base.displayable(::TerminalGraphicDisplay, ::MIME"image/png", x::Any) = showable("image/png", x)
Base.displayable(::TerminalGraphicDisplay, ::MIME"image/png", ::Vector{UInt8}) = true
Base.displayable(::TerminalGraphicDisplay, ::MIME"image/png", ::AbstractArray{<:Colorant}) = true

function Base.display(d::TerminalGraphicDisplay, ::MIME"image/png", x::Any)
    io = IOBuffer()
    show(io, "image/png", x)
    display(d, MIME("image/png"), FileIO.load(io))
end

function Base.display(d::TerminalGraphicDisplay, ::MIME"image/png", bytes::Vector{UInt8})
    # In this case, assume it to be png byte sequences, use FileIO to find a decoder for it.
    img = FileIO.load(FileIO.Stream{format"PNG"}(PipeBuffer(bytes)))
    display(d, MIME("image/png"), img)
end

function Base.display(
    d::TerminalGraphicDisplay, ::MIME"image/png", img::AbstractArray{<:Colorant}
)
    SUMMARY[] && println(d.summary_stream, summary(img), ":")
    ImageInTerminal.imshow(d.content_stream, img)
    nothing
end
