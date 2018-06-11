using Documenter, Makie
cd(@__DIR__)
include("../examples/library.jl")
include("documenter_extension.jl")
using Makie: to_string

# =============================================
# automatically generate an overview of the atomic functions
path = joinpath(@__DIR__, "..", "docs", "src", "functions-autogen.md")
open(path, "w") do io
    println(io, "# `Makie.jl` Functions -- autogenerated")
    for func in atomics
        println(io, "## `$(to_string(func))`")
        try
            Makie._help(io, func; extended = true)
        catch
            println("ERROR: Didn't work with $func\n")
        end
        println(io, "\n")
    end
end

# =============================================
# automatically generate an detailed overview of each of the atomic functions
atomics_pages = nothing
atomics_list = String[]
atomic_example_folder = joinpath(@__DIR__, "..", "docs", "src", "atomics_examples")
isdir(atomic_example_folder) || mkdir(atomic_example_folder)

for func in atomics
    path = joinpath(atomic_example_folder, "$(to_string(func)).md")
    open(path, "w") do io
        println(io, "# `$(to_string(func))`")
        # println(io, "## `$func`")
        try
            Makie._help(io, func; extended = true)
        catch
            println("ERROR: Didn't work with $func\n")
        end
        println(io, "\n")
    end
    push!(atomics_list, "atomics_examples/$(to_string(func)).md")
end
atomics_pages = "Atomic Functions" => atomics_list

# =============================================
# automatically generate gallery based on tags - all examples
tags_list = sort(unique(tags_list))
path = joinpath(@__DIR__, "..", "docs", "src", "examples-for-tags.md")
open(path, "w") do io
    println(io, "# List of all tags including all examples from each tag")
    println(io, "## List of all tags, sorted alphabetically")
    for tag in tags_list
        println(io, "  * [$tag](@ref tag_$(replace(tag, " ", "_")))")
    end
    println(io, "\n")
    for tag in tags_list
        counter = 1
        # search for the indices where tag is found
        indices = find_indices(tag; title = nothing, author = nothing)
        # # pick a random example from the list
        # idx = indices[rand(1:length(indices))];
        println(io, "## [$tag](@id tag_$(replace(tag, " ", "_")))")
        for idx in indices
            try
                println(io, "### Example $counter, \"$(database[idx].title)\"")
                _print_source(io, idx; style = "julia")
                println(io, "`plot goes here\n`")
                # TODO: add code to generate + embed plots
                counter += 1
            catch
                println("ERROR: Didn't work with $tag at index $idx\n")
            end
        end
        println(io, "\n")
    end
end

# =============================================
# automatically generate gallery based on looping through the database - all examples
# TODO: FYI: database[44].title == "Theming Step 1"
pathroot = joinpath(@__DIR__, "..", "docs", "src")
buildpath = joinpath(@__DIR__, "build")
imgpath = joinpath(pathroot, "plots")
path = joinpath(pathroot, "examples-database.md")
open(path, "w") do io
    println(io, "# Examples gallery")
    counter = 1
    groupid_last = NO_GROUP
    for (i, entry) in enumerate(database)
        # print bibliographic stuff
        println(io, "## $(entry.title)")
        # println(io, "line(s): $(entry.file_range)\n")
        print(io, "Tags: ")
        tags = collect(entry.tags)
        for j = 1:length(tags) - 1; print(io, "`$(tags[j])`, "); end
        println(io, "`$(tags[end])`.\n")
        if isgroup(entry) && entry.groupid == groupid_last
            try
                # println(io, "condition 2 -- group continuation\n")
                # println(io, "group ID = $(entry.groupid)\n")
                println(io, "Example $counter, \"$(entry.title)\"\n")
                _print_source(io, i; style = "example", example_counter = counter)
                filename = string(entry.unique_name)
                # plotting
                    println(io, "```@example $counter")
                    # println(io, "println(STDOUT, \"Example $(counter) \", \"$(entry.title)\", \" index $i\")")
                    # println(io, "Makie.save(joinpath(imgpath, \"$(filename).png\"), scene)")
                    println(io, "Makie.save(\"$(filename).png\", scene) # hide")
                    println(io, "```")
                # embed plot
                # println(io, "![]($(joinpath(relpath(imgpath, buildpath), "$(filename).png")))")
                println(io, "![]($(filename).png)")
            catch
                println("ERROR: Didn't work with \"$(entry.title)\" at index $i\n")
            end
        elseif isgroup(entry)
            try
                # println(io, "condition 1 -- new group encountered!\n")
                # println(io, "group ID = $(entry.groupid)\n")
                groupid_last = entry.groupid
                println(io, "Example $counter, \"$(entry.title)\"\n")
                _print_source(io, i; style = "example", example_counter = counter)
                filename = string(entry.unique_name)
                # plotting
                    println(io, "```@example $counter")
                    # println(io, "println(STDOUT, \"Example $(counter) \", \"$(entry.title)\", \" index $i\")")
                    # println(io, "Makie.save(joinpath(imgpath, \"$(filename).png\"), scene)")
                    println(io, "Makie.save(\"$(filename).png\", scene) # hide")
                    println(io, "```")
                # embed plot
                # println(io, "![]($(joinpath(relpath(imgpath, buildpath), "$(filename).png")))")
                println(io, "![]($(filename).png)")
            catch
                println("ERROR: Didn't work with \"$(entry.title)\" at index $i\n")
            end
        else
            try
                # println(io, "condition 3 -- not part of a group\n")
                println(io, "Example $counter, \"$(entry.title)\"\n")
                _print_source(io, i; style = "example", example_counter = counter)
                filename = string(entry.unique_name)
                # plotting
                    println(io, "```@example $counter")
                    # println(io, "println(STDOUT, \"Example $(counter) \", \"$(entry.title)\", \" index $i\")")
                    # println(io, "Makie.save(joinpath(imgpath, \"$(filename).png\"), scene)")
                    println(io, "Makie.save(\"$(filename).png\", scene) # hide")
                    println(io, "```")
                # embed plot
                # println(io, "![]($(joinpath(relpath(imgpath, buildpath), "$(filename).png")))")
                println(io, "![]($(filename).png)")
                counter += 1
                groupid_last = entry.groupid
            catch
                println("ERROR: Didn't work with \"$(entry.title)\" at index $i\n")
            end
        end
    end
end

makedocs(
    modules = [Makie],
    doctest = false, clean = true,
    format = :html,
    sitename = "Makie.jl",
    pages = Any[
        "Home" => "index.md",
        "Basics" => [
            # "scene.md",
            # "conversions.md",
            "help_functions.md",
            "functions-autogen.md",
            "functions.md"
            # "documentation.md",
            # "backends.md",
            # "extending.md",
            # "themes.md",
            # "interaction.md",
            # "axis.md",
            # "legends.md",
            # "output.md",
            # "reflection.md",
            # "layout.md"
        ],
        atomics_pages,
        "Examples" => [
            "examples-for-tags.md",
            "examples-database.md",
            "tags_wordcloud.md",
            #"linking-test.md"
        ]
        # "Developper Documentation" => [
        #     "devdocs.md",
        # ],
    ]
)


#
# ENV["TRAVIS_BRANCH"] = "latest"
# ENV["TRAVIS_PULL_REQUEST"] = "false"
# ENV["TRAVIS_REPO_SLUG"] = "github.com/SimonDanisch/MakieDocs.git"
# ENV["TRAVIS_TAG"] = "tag"
# ENV["TRAVIS_OS_NAME"] = "linux"
# ENV["TRAVIS_JULIA_VERSION"] = "0.6"
#
# deploydocs(
#     deps   = Deps.pip("mkdocs", "python-markdown-math", "mkdocs-cinder"),
#     repo   = "github.com/SimonDanisch/MakieDocs.git",
#     julia  = "0.6",
#     target = "build",
#     osname = "linux",
#     make = nothing
# )
