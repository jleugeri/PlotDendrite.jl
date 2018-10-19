using PlotDendrite, Compose, Colors, Test

structure = (name="A", SC=[RGB(0.3, 0.3, 0.3),RGB(0.3, 0.7, 0.3),"black","pink"], DW=1.0, DC="red", branches=[
    (name="B1", SC=["black", "black"], DW=1.0, DC="blue", branches=[]),
    (name="B2", SC=["black", "black"], DW=0.75, DC="blue", branches=[]),
    (name="B3", SC=["black", "black"], DW=0.5, DC="yellow", branches=[
        (name="C1", SC=["orange"], DW=1.0, DC="brown",branches=[]),
        (name="C2", SC=["orange"], DW=1.0, DC="brown", branches=[])
    ])
])

kwargs = (h_frac=0.5, style=[])
res = plotDendrite(structure, canvas=SVG("test.svg", 15cm,10cm))

@testset "plotting" begin
    @test res.height == 4
    @test res.width  == 10
    @test isfile("test.svg")
end
