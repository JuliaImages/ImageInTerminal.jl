abstract type TermColorDepth end

@inline (enc::TermColorDepth)(c::Color) = enc(RGB(c))
@inline (enc::TermColorDepth)(c::TransparentColor) = enc(color(c))

"""
    TermColor256()

The RGB/Grayscale to xterm-256 color codes encoder. Other color types will be converted
to RGB first. The transparent alpha channel, if exists, will be dropped.

The encoder works as a functor `enc(color)`:

```jldoctest; setup=:(using ImageBase; using AsciiPixel: TermColor256)
julia> enc = TermColor256()
AsciiPixel.TermColor256()

julia> enc(RGB(1.0, 1.0, 0.0))
226

julia> enc(RGB(0.5, 0.5, 0.5))
244
```
"""
struct TermColor256 <: TermColorDepth end

function (enc::TermColor256)(c::AbstractRGB)
    r, g, b = clamp01nan(red(c)), clamp01nan(green(c)), clamp01nan(blue(c))
    r24, g24, b24 = map(c->round(Int, c * 23), (r, g, b))
    if r24 == g24 == b24
        # Use grayscales because of higher resolution
        # This way even grayscale RGB images look good.
        232 + r24
    else
        r6, g6, b6 = map(c->round(Int, c * 5), (r, g, b))
        16 + 36 * r6 + 6 * g6 + b6
    end
end
(enc::TermColor256)(c::AbstractGray) = round(Int, 232 + clamp01nan(real(c)) * 23)


"""
    TermColor24bit()

The RGB/Grayscale to 24bit color (truecolor) codes encoder. Other color types will be converted
to RGB first. The transparent alpha channel, if exists, will be dropped.

The encoder works as a functor `enc(color)`:

```jldoctest; setup=:(using ImageBase; using AsciiPixel: TermColor24bit)
julia> enc = TermColor24bit()
AsciiPixel.TermColor24bit()

julia> enc(RGB(1.0, 1.0, 0.0))
(255, 255, 0)

julia> enc(RGB(0.5, 0.5, 0.5))
(128, 128, 0)
```
"""
struct TermColor24bit <: TermColorDepth end

function (enc::TermColor24bit)(c::AbstractRGB)
    r, g, b = red(c), green(c), blue(c)
    map(c->round(Int, clamp01nan(c) * 255), (r, g, b))
end

function (enc::TermColor24bit)(c::AbstractGray)
    r = round(Int, clamp01nan(real(c)) * 255)
    r, r, r
end
