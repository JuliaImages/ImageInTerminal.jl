using ImageInTerminal, ImageCore, ColorTypes, FixedPointNumbers, TestImages
using Base.Test

reference_path(filename) = joinpath(dirname(@__FILE__), "reference", "$(filename).txt")

function test_reference_impl(filename, actual)
    try
        reference = replace.(readlines(reference_path(filename)), ["\n"], [""])
        try
            @test reference == actual
            @assert reference == actual # to throw error
        catch # test failed
            if isinteractive()
                println("Test for \"$filename\" failed.")
                println("- REFERENCE -------------------")
                println.(reference)
                println("-------------------------------")
                println("- ACTUAL ----------------------")
                println.(actual)
                println("-------------------------------")
                print("Replace reference with actual result? [y/n] ")
                answer = first(readline())
                if answer == 'y'
                    write(reference_path(filename), join(actual, "\n"))
                end
            end
        end
    catch # File doesn't exist
        if isinteractive()
            println("Reference file for \"$filename\" does not exist. Do you want to create it with the following content?")
            println("- NEW CONTENT -----------------")
            println.(actual)
            println("-------------------------------")
            print("Create reference file with above content? [y/n] ")
            answer = first(readline())
            if answer == 'y'
                write(reference_path(filename), join(actual, "\n"))
            end
        end
    end
end

# using a macro looks more consistent
macro test_reference(filename, expr)
    :(test_reference_impl($filename, $expr))
end

tests = [
    "tst_colorant2ansi.jl",
    "tst_encodeimg.jl",
]

for t in tests
    @testset "$t" begin
        include(t)
    end
end

