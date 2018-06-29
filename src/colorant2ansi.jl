abstract type TermColorDepth end
struct TermColor256   <: TermColorDepth end
struct TermColor24bit <: TermColorDepth end

"""
    colorant2ansi(color::Colorant) -> Int

Converts the given colorant into an integer index that corresponds
to the closest 256-colors ANSI code.

```julia
julia> colorant2ansi(RGB(1., 1., 0.))
226
```

This function also tries to make good use of the additional number
of available shades of gray (ANSI codes 232 to 255).

```julia
julia> colorant2ansi(RGB(.5, .5, .5))
244

julia> colorant2ansi(Gray(.5))
244
```
"""
colorant2ansi(color) = _colorant2ansi(color, TermColor256())

# Fallback for non-rgb and transparent colors (convert to rgb)
_colorant2ansi(gr::Color, colordepth::TermColorDepth) =
    _colorant2ansi(convert(RGB, gr), colordepth)
_colorant2ansi(gr::TransparentColor, colordepth::TermColorDepth) =
    _colorant2ansi(color(gr), colordepth)

# 256 colors
function _colorant2ansi(col::AbstractRGB, ::TermColor256)
    r, g, b = clamp01nan(red(col)), clamp01nan(green(col)), clamp01nan(blue(col))
    r24, g24, b24 = map(c->round(Int, c * 23), (r, g, b))
    if r24 == g24 == b24
        # Use grayscales because of higher resultion
        # This way even grayscale RGB images look good.
        232 + r24
    else
        r6, g6, b6 = map(c->round(Int, c * 5), (r, g, b))
        16 + 36 * r6 + 6 * g6 + b6
    end
end

_colorant2ansi(gr::Color{<:Any,1}, ::TermColor256) = round(Int, 232 + clamp01nan(real(gr)) * 23)

# 24 bit colors
function _colorant2ansi(col::AbstractRGB, ::TermColor24bit)
    r, g, b = clamp01nan(red(col)), clamp01nan(green(col)), clamp01nan(blue(col))
    map(c->round(Int, c * 255), (r, g, b))
end

function _colorant2ansi(gr::Color{<:Any,1}, ::TermColor24bit)
    r = round(Int, clamp01nan(real(gr)) * 255)
    r, r, r
end

