@testset "encoder/sixel" begin
    # Force sixel encoding
    old_encoder = ImageInTerminal.encoder_backend[1]
    ImageInTerminal.encoder_backend[1] = :Sixel

    @testset "lena" begin
        img = imresize(lena, 128, 128)
        io = IOBuffer()
        imshow256(io, img)
        seek(io, 0)
        # we can't reference test it right now, because ReferenceTests calls
        # FileIO.load, which returns an array for sixel file.
        @test assess_psnr(sixel_decode(io), img) > 30
    end
    @testset "small images" begin
        # small images still use ImageInTerminal for encoding
        img = imresize(lena, 10, 10)
        io = IOBuffer()
        ensurecolor(imshow256, io, img)
        res = replace.(readlines(seek(io,0)), Ref("\n" => ""))
        @test_reference "reference/lena_sixel_small.txt" res
    end

    # restore encoder to previous one
    ImageInTerminal.encoder_backend[1] = old_encoder
end
