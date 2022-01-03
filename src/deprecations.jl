## BEGIN v0.5
export colorant2ansi
function colorant2ansi(c::Colorant)
    Base.depwarn("colorant2ansi(c) is deprecated, use `TermColor256` or `TermColor24bit` instead.", :colorant2ansi)
    TermColor256()(c)
end
## END v0.5
