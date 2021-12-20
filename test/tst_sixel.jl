@testset "encoder/sixel" begin
    # Force sixel encoding
    old_encoder = ImageInTerminal.encoder_backend[]
    ImageInTerminal.encoder_backend[] = :Sixel

    @testset "monarch" begin
        img = imresize(monarch, 128, 128)
        io = IOBuffer()
        imshow256(io, img)
        seek(io, 0)
        # we can't reference test it right now, because ReferenceTests calls
        # FileIO.load, which returns an array for sixel file.
        @test assess_psnr(sixel_decode(io), img) > 30
    end
    @testset "small images" begin
        # small images still use ImageInTerminal's fallback encoding
        img = imresize(monarch, 10, 10)
        io = IOBuffer()
        ensurecolor(imshow256, io, img)
        res = replace.(readlines(seek(io, 0)), Ref("\n"=>""))[1]
        @test !startswith(res, "\ePq\"")  # not sixel encoding
    end
    @testset "vector" begin
        # vectors, no matter how large it is, does not use sixel
        img = rgb_line
        io = IOBuffer()
        ensurecolor(imshow256, io, img)
        res = replace.(readlines(seek(io, 0)), Ref("\n"=>""))[1]
        @test !startswith(res, "\ePq\"")  # not sixel encoding

        io = IOBuffer()
        img = repeat(img, 10)
        ensurecolor(imshow256, io, img)
        res = replace.(readlines(seek(io, 0)), Ref("\n"=>""))[1]
        @test !startswith(res, "\ePq\"")  # not sixel encoding
    end

    # restore encoder to previous one
    ImageInTerminal.encoder_backend[] = old_encoder
end
