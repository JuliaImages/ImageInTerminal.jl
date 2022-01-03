@testset "Deprecations" begin
    for c in (rand(RGB), rand(Gray))
        @test colorant2ansi(c) == TermColor256()(c)
    end
end
