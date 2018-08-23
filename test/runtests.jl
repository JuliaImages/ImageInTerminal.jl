using ImageInTerminal, ImageCore, ColorTypes, FixedPointNumbers
using TestImages, ImageTransformations, CoordinateTransformations
using ImageMagick
using Rotations, OffsetArrays
using SparseArrays
using Test

reference_path(filename) = joinpath(dirname(@__FILE__), "reference", "$(filename).txt")

function test_reference_impl(filename, actual)
    try
        reference = replace.(readlines(reference_path(filename)), Ref("\n" => ""))
        try
            @assert reference == actual # to throw error
            @test true # to increase test counter if reached
        catch # test failed
            println("Test for \"$filename\" failed.")
            println("- REFERENCE -------------------")
            println.(reference)
            println("-------------------------------")
            println("- ACTUAL ----------------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Replace reference with actual result? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(reference_path(filename), join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update reference images")
            end
        end
    catch ex
        if isa(ex, SystemError) # File doesn't exist
            println("Reference file for \"$filename\" does not exist.")
            println("- NEW CONTENT -----------------")
            println.(actual)
            println("-------------------------------")
            if isinteractive()
                print("Create reference file with above content? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(reference_path(filename), join(actual, "\n"))
                end
            else
                error("You need to run the tests interactively with 'include(\"test/runtests.jl\")' to create new reference images")
            end
        else
            throw(ex)
        end
    end
end

# using a macro looks more consistent
macro test_reference(filename, expr)
    esc(:(test_reference_impl($filename, $expr)))
end

function ensurecolor(f, args...)
    old_color = Base.have_color
    try
        Core.eval(Base, :(have_color = true))
        return @inferred f(args...)
    finally
        Core.eval(Base, :(have_color = $old_color))
    end
end

# ====================================================================

# define some test images
gray_square = colorview(Gray, N0f8[0. 0.3; 0.7 1])
gray_square_alpha = colorview(GrayA, N0f8[0. 0.3; 0.7 1], N0f8[1 0.7; 0.3 0])
gray_line = colorview(Gray, N0f8[0., 0.3, 0.7, 1])
gray_line_alpha = colorview(GrayA, N0f8[0., 0.3, 0.7, 1], N0f8[1, 0.7, 0.3, 0])
rgb_line = colorview(RGB, range(0, stop=1, length=20), zeroarray, range(1, stop=0, length=20))

camera_man = testimage("camera")
lighthouse = testimage("lighthouse")
toucan = testimage("toucan")
lena = testimage("lena_color_256")

# ====================================================================

tests = [
    "tst_colorant2ansi.jl",
    "tst_encodeimg.jl",
    "tst_imshow.jl",
    "tst_baseshow.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end
