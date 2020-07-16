using Dates

function hfun_blogposts()
    io = IOBuffer()
    posts = sort!(filter!(x -> endswith(x, ".md") && x != "index.md", readdir(joinpath(@__DIR__, "blog"))); rev=true)
    for post in first.(splitext.(posts))
        url = splitext("/blog/$post/")[1]
        title = pagevar(strip(url, '/'), :title)
        date = Date(post[1:10])
        date ≤ today() && write(io, "\n[$title]($url) $date \n")
    end
    return Franklin.fd2html(String(take!(io)), internal=true)
end

