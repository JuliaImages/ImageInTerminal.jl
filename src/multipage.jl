
ansi_moveup(n::Int) = string("\e[", n, "A")
ansi_movecol1 = "\e[1G"
ansi_cleartoend = "\e[0J"
ansi_enablecursor = "\e[?25h"
ansi_disablecursor = "\e[?25l"

setraw!(io, raw) = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), io.handle, raw)

"""
    play(io::IO, arr::T, dim::Int; kwargs...)
    play(io::IO, framestack::Vector{T}; kwargs...) where {T<:AbstractArray}

Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

Control keys:
- `p` or `space-bar`: pause
- `left` or `up-arrow`: step backward
- `right` or `down-arrow`: step forward
- `ctrl-c` or `q`: exit

kwargs:
- `fps::Real=30`
- `maxsize::Tuple = displaysize(io)`
"""
function play(io::IO, arr::T, dim::Int; fps::Real=30, maxsize::Tuple = displaysize(io), paused = false) where {T<:AbstractArray}
    @assert dim <= ndims(arr) "Requested dimension $dim, but source array only has $(ndims(arr)) dimensions"
    @assert ndims(arr) <= 3 "Source array dimensions cannot exceed 3"
    firstframe = T <: Vector ? first(selectdim(arr, dim, 1)) : selectdim(arr, dim, 1)
    @assert eltype(firstframe) <: Colorant "Element type $(eltype(firstframe)) not supported"
    # sizing
    img_w, img_h = size(firstframe)
    io_h, io_w = maxsize
    blocks = 3img_w <= io_w ? BigBlocks() : SmallBlocks()

    # fixed
    nframes = size(arr, dim)
    c = ImageInTerminal.colormode[]

    # vars
    frame = 1
    finished = false
    first_print = true
    actual_fps = 0

    println(summary(firstframe))
    keytask = @async begin
        try
            setraw!(stdin, true)
            while !finished
                keyin = read(stdin, Char)
                if UInt8(keyin) == 27
                    keyin = read(stdin, Char)
                    if UInt8(keyin) == 91
                        keyin = read(stdin, Char)
                        UInt8(keyin) in [68,65] && (frame = frame <= 1 ? 1 : frame - 1) # left & up arrows
                        UInt8(keyin) in [67,66] && (frame = frame >= nframes ? nframes : frame + 1) # right & down arrows
                    end
                end
                keyin in ['p',' '] && (paused = !paused)
                keyin in ['\x03','q'] && (finished = true)
            end
        catch
        finally
            setraw!(stdin, false)
        end
    end
    try
        print(ansi_disablecursor)
        setraw!(stdin, true)
        while !finished
            tim = Timer(1/fps)
            t = @elapsed begin
                img = T <: Vector ? collect(first(selectdim(arr, dim, frame))) : selectdim(arr, dim, frame)
                lines, rows, cols = encodeimg(blocks, c, img, io_h, io_w)
                str = sprint() do ios
                    println.((ios,), lines)
                    if paused
                        println(ios, "Preview: $(cols)x$(rows) Frame: $frame/$nframes", " "^15)
                    else
                        println(ios, "Preview: $(cols)x$(rows) Frame: $frame/$nframes FPS: $(round(actual_fps, digits=1))", " "^5)
                    end
                    println(ios, "exit: ctrl-c. play/pause: space-bar. seek: arrow keys")
                end
                first_print ? print(str) : print(ansi_moveup(rows+2), ansi_movecol1, str)
                first_print = false
                (!paused && frame == nframes) && break
                !paused && (frame += 1)
                wait(tim)
            end
            actual_fps = 1 / t
        end
    catch e
        isa(e,InterruptException) || rethrow()
    finally
        print(ansi_enablecursor)
        finished = true
        @async Base.throwto(keytask, InterruptException())
        wait(keytask)
    end
    return
end
play(arr::T, dim::Int; kwargs...) where {T<:AbstractArray} = play(stdout, arr, dim; kwargs...)
play(io::IO, framestack::Vector{T}; kwargs...) where {T<:AbstractArray} = play(io, framestack, 1; kwargs...)

"""
    explore(io::IO, arr::T, dim::Int; kwargs...) where {T<:AbstractArray}
    explore(arr::T, dim::Int; kwargs...) where {T<:AbstractArray}
    explore(io::IO, framestack::Vector{T}; kwargs...) where {T<:AbstractArray}
    explore(framestack::Vector{T}; kwargs...) where {T<:AbstractArray}

Like `play`, but starts paused
"""
explore(io::IO, arr::T, dim::Int; kwargs...) where {T<:AbstractArray} = play(io, arr, dim; paused=true, kwargs...)
explore(arr::T, dim::Int; kwargs...) where {T<:AbstractArray} = play(stdout, arr, dim; paused=true, kwargs...)
explore(io::IO, framestack::Vector{T}; kwargs...) where {T<:AbstractArray} = explore(io, framestack, 1; kwargs...)
explore(framestack::Vector{T}; kwargs...) where {T<:AbstractArray} = explore(stdout, framestack, 1; kwargs...)
