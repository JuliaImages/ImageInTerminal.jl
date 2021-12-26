@testset "encoder/sixel" begin
    # Force sixel encoding
    old_encoder = ImageInTerminal.encoder_backend[]
    ImageInTerminal.encoder_backend[] = :Sixel

    @testset "mandril" begin
        img = imresize(mandril, 128, 128)
        io = IOBuffer()
        imshow256(io, img)
        # we can't reference test it right now, because ReferenceTests calls
        # FileIO.load, which returns an array for sixel file.
        @test assess_psnr(sixel_decode(seek(io, 0)), img) > 30
    end
    @testset "small images" begin
        # small images still use ImageInTerminal's fallback encoding
        img = imresize(mandril, 10, 10)
        io = PipeBuffer()
        @ensurecolor imshow256(io, img)
        @test !startswith(readlines(io)[1], "\ePq\"")  # not sixel encoding
    end
    @testset "vector" begin
        # vectors, no matter how large it is, does not use sixel
        img = rgb_line
        io = PipeBuffer()
        @ensurecolor imshow256(io, img)
        @test !startswith(readlines(io)[1], "\ePq\"")  # not sixel encoding

        io = PipeBuffer()
        img = repeat(img, 10)
        @ensurecolor imshow256(io, img)
        @test !startswith(readlines(io)[1], "\ePq\"")  # not sixel encoding
    end

    # restore encoder to previous one
    ImageInTerminal.encoder_backend[] = old_encoder
end
