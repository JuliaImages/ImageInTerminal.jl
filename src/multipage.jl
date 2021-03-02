ansi_moveup(n::Int) = string("\e[", n, "A")
ansi_movecol1 = "\e[1G"
ansi_cleartoend = "\e[0J"
ansi_enablecursor = "\e[?25h"
ansi_disablecursor = "\e[?25l"

"""
    play(io::IO, arr::T, dim::Int; kwargs...)
    play(io::IO, framestack::Vector{T}; kwargs...) where {T<:AbstractArray}

Play a video of a framestack of image arrays, or 3D array along dimension `dim`.

Control keys:
- `p` or `space-bar`: pause/resume
- `f`, `←`(left arrow), or `↑`(up arrow): step backward
- `b`, `→`(right arrow), or `↓`(down arrow): step forward
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

    # fixed
    nframes = size(arr, dim)

    # vars
    frame_idx = 1
    actual_fps = 0
    should_exit = false

    keytask = @async begin
        while !should_exit
            control_value = read_key()

            if control_value == :CONTROL_BACKWARD
                frame_idx = max(frame_idx-1, 1)
            elseif control_value == :CONTROL_FORWARD
                frame_idx = min(frame_idx+1, nframes)
            elseif control_value == :CONTROL_PAUSE
                paused = !paused
            elseif control_value == :CONTROL_EXIT
                should_exit = true
            elseif control_value == :CONTROL_VOID
                nothing
            else
                error("Control value $control_value not recognized.")
            end
        end
    end

    print(ansi_disablecursor)
    println(summary(selectdim(arr, dim, 1)))
    render_frame(arr, dim, frame_idx, nframes, actual_fps, maxsize; first_frame=true)

    try
        while !should_exit && 1<= frame_idx <= nframes
            fps_value = paused ? 0 : actual_fps
            actual_fps = fixed_fps(fps) do
                render_frame(arr, dim, frame_idx, nframes, fps_value, maxsize)
            end
            paused || (frame_idx += 1)
        end
    catch e
        e isa InterruptException || rethrow(e)
    finally
        print(ansi_enablecursor)
        # stop running read_key task so that REPL/stdin is not blocked
        @async Base.throwto(keytask, InterruptException())
        wait(keytask)
    end
    return nothing
end

function render_frame(arr, dim, frame_idx, nframes, actual_fps, maxsize; first_frame=false)
    frame = selectdim(arr, dim, frame_idx)

    # sizing
    frame_w, frame_h = size(frame)
    io_h, io_w = maxsize
    blocks = 3frame_w <= io_w ? BigBlocks() : SmallBlocks()

    lines, rows, cols = encodeimg(blocks, ImageInTerminal.colormode[], frame, io_h, io_w)
    if !first_frame
        print(ansi_moveup(rows+2), ansi_movecol1)
    end
    println.(lines)
    println("Preview: $(cols)x$(rows) Frame: $frame_idx/$nframes FPS: $(round(actual_fps, digits=1))", " "^5)
    println("exit: ctrl-c. play/pause: space-bar. seek: arrow keys")
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


# minimal keyboard event support
"""
    read_key() -> control_value

read control key from keyboard input.

# Reference table

| value               | control_value     | effect                 |
| ------------------- | ----------------- | -------------------    |
| UP, LEFT, f, F      | :CONTROL_BACKWARD | show previous frame    |
| DOWN, RIGHT, b, B   | :CONTROL_FORWARD  | show next frame        |
| SPACE, p, P         | :CONTROL_PAUSE    | pause/resume play      |
| CTRL-c, q, Q        | :CONTROL_EXIT     | exit current play      |
| others...           | :CONTROL_VOID     | no effect              |
"""
function read_key()
    setraw!(io, raw) = ccall(:jl_tty_set_mode, Int32, (Ptr{Cvoid},Int32), io.handle, raw)
    control_value = :CONTROL_VOID
    try
        setraw!(stdin, true)
        keyin = read(stdin, Char)
        if keyin == '\e'
            # some special keys are more than one bit, e.g., left key is `\e[D`
            # reference: https://en.wikipedia.org/wiki/ANSI_escape_code
            keyin = read(stdin, Char)
            if keyin == '['
                keyin = read(stdin, Char)
                if keyin in ['A', 'D'] # up, left
                    control_value = :CONTROL_BACKWARD
                elseif keyin in ['B', 'C'] # down, right
                    control_value = :CONTROL_FORWARD
                end
            end
        elseif 'A' <= keyin <= 'Z' || 'a' <= keyin <= 'z'
            keyin = lowercase(keyin)
            if keyin == 'p'
                control_value = :CONTROL_PAUSE
            elseif keyin == 'q'
                control_value = :CONTROL_EXIT
            elseif keyin == 'f'
                control_value = :CONTROL_FORWARD
            elseif keyin == 'b'
                control_value = :CONTROL_BACKWARD
            end
        elseif keyin == ' '
            control_value = :CONTROL_PAUSE
        end
    catch e
        if e isa InterruptException # Ctrl-C
            control_value = :CONTROL_EXIT
        else
            rethrow(e)
        end
    finally
        setraw!(stdin, false)
    end
    return control_value
end

"""
    fixed_fps(f::Function, fps)

Run function f() at a fixed fps rate if possible.
"""
function fixed_fps(f, fps)
    tim = Timer(1/fps)
    t = @elapsed f()
    wait(tim)
    close(tim)
    return 1/t
end
