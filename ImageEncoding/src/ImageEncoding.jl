module ImageEncoding

using ImageBase: restrict
using ImageCore
using Requires
using Crayons

export
  TermColorDepth, TermColor256, TermColor24bit,
  ImageEncoder, BigBlocks, SmallBlocks,
  colorant2ansi, encodeimg, sixel_encode

include("colorant2ansi.jl")
include("encodeimg.jl")

function __init__()
    # Sixel requires Julia at least v1.6. We don't want to maintain an ImageInTerminal branch
    # for old Julia versions so here we use Requires to conditionally load Sixel as an advanced
    # image encoding choice. All ImageInTerminal functionality is still there even without Sixel
    # -- well, basically.
    @require Sixel = "45858cf5-a6b0-47a3-bbea-62219f50df47" begin
        Sixel.is_sixel_supported() && (encoder_backend[] = :Sixel)
        sixel_encode(args...; kwargs...) = Sixel.sixel_encode(args...; kwargs...)
    end
end

end # module