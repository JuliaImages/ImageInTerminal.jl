abstract TermColorDepth
immutable TermColor256   <: TermColorDepth end
immutable TermColor24bit <: TermColorDepth end

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
function colorant2ansi(col::AbstractRGB)
    r, g, b = red(col), green(col), blue(col)
    r24 = round(Int, r * 23)
    g24 = round(Int, g * 23)
    b24 = round(Int, b * 23)
    if r24 == g24 == b24
        # Use grayscales because of higher resultion
        # This way even grayscale RGB images look good.
        232 + r24
    else
        r6 = round(Int, r * 5)
        g6 = round(Int, g * 5)
        b6 = round(Int, b * 5)
        16 + 36 * r6 + 6 * g6 + b6
    end
end

colorant2ansi{T}(gr::Color{T,1}) = round(Int, 232 + real(gr) * 23)

# Fallback for non-rgb and transparent colors (convert to rgb)
colorant2ansi(gr::Color) = colorant2ansi(convert(RGB, gr))
colorant2ansi(gr::TransparentColor) = colorant2ansi(color(gr))

# -------------------------------------------------------------------
# unexported version that can also return a 24bit RGB tuple

_colorant2ansi(color, ::TermColor256) = colorant2ansi(color)

# 24 bit colors
function _colorant2ansi(col::AbstractRGB, ::TermColor24bit)
    r, g, b = red(col), green(col), blue(col)
    round(Int, r * 255), round(Int, g * 255), round(Int, b * 255)
end

function _colorant2ansi{T}(gr::Color{T,1}, ::TermColor24bit)
    r = round(Int, real(gr) * 255)
    r, r, r
end

# Fallback for non-rgb and transparent colors (convert to rgb)
_colorant2ansi(gr::Color, ::TermColor24bit) =
    _colorant2ansi(convert(RGB, gr), colordepth)
_colorant2ansi(gr::TransparentColor, ::TermColor24bit) =
    _colorant2ansi(color(gr), colordepth)

