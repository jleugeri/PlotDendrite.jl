using PlotDendrite, Compose, Colors, Test

structure = ("A", [RGB(0.3, 0.3, 0.3),RGB(0.3, 0.7, 0.3),"black","pink"], 1.0, "red", [("B1", ["black", "black"], 1.0, "blue", []),("B2", ["black", "black"], 0.75, "blue", []),("B3", ["black", "black"], 0.5, "yellow", [("C1", ["orange"], 1.0, "brown",[]),("C2", ["orange"], 1.0, "brown", [])])])
kwargs = (h_frac=0.5, style=[])
res = plotDendrite(structure..., canvas=SVG("test.svg", 15cm,10cm))

@testset "plotting" begin
    @test res.height == 4
    @test res.width  == 10
    @test isfile("test.svg")
end
