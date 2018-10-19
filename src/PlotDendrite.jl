
module PlotDendrite
export plotDendrite
using Compose
const offset = 1 # how many synapse widths correspond to the connector width

function _draw_branch(root; fill_connectors=false, connector_style= fill_connectors ? [] : [stroke("black"), linewidth(1)], style=[stroke("black")], h_frac=0.5, font_style=[stroke("black"), fill("white"), fontsize(12), linewidth(0.1)], kwargs...)
    branch_drawings = []
    branch_root_loc = Tuple{Float64,Float64}[]
    branch_total_lengths = Int64[]
    branch_total_branches = Int64[]
    for branch ∈ root.branches
        branch_drawing, branch_total_length, branch_total_branches_, by0, by1 = _draw_branch(branch; fill_connectors=fill_connectors, connector_style=connector_style, style=style, h_frac=h_frac, font_style=font_style, kwargs...)
        push!(branch_drawings, branch_drawing)
        push!(branch_root_loc, (by0, by1))
        push!(branch_total_lengths, branch_total_length)
        push!(branch_total_branches, branch_total_branches_)
    end
    total_branches = isempty(branch_total_branches) ? 1 : sum(branch_total_branches)
    branch_length = length(root.SC) + offset
    branches_total_length = isempty(branch_total_lengths) ? 0 : maximum(branch_total_lengths)
    total_length = branches_total_length + branch_length
    width  = branch_length/total_length
    height  = (1/total_branches)*h_frac*root.DW
    x0 = 1-width
    y0 = (1-height)*0.5 + 0.5/total_length#0.5-0.5*height# + 0.75*1/(aspect)/total_length
    lw = 1/total_length
    
    branch_heights = branch_total_branches./total_branches
    branch_ys      = cumsum([0.0;branch_heights[1:end-1]])

    drawing = (
            context(0.01,0.01, 0.98, 0.98),
            # draw stem
            (context(x0,0,width,1), fill(root.DC),
                (context(offset/branch_length, y0, 1-offset/branch_length, height), 
                    # draw rectangle representing the stem
                    rectangle(),
                    # write name
                    (context(), text(0.5, 0.5, root.name, hcenter, vcenter), font_style...)
                ),
                # draw connectors
                if fill_connectors # filled connectors in parent context
                    [[
                        polygon([(0,branch_ys[i]+by0*branch_heights[i]),(0,branch_ys[i]+by1*branch_heights[i]),(offset/branch_length,y0+height),(offset/branch_length,y0)]) for (i,(by0,by1)) ∈ enumerate(branch_root_loc)
                    ]; connector_style...]
                else # bezier connectors in their own context
                    [(context(), [
                        curve((0,branch_ys[i]+0.5*(by0+by1)*branch_heights[i]), (0.7*offset/branch_length,branch_ys[i]+0.5*(by0+by1)*branch_heights[i]), (0.3*offset/branch_length,y0+height*i/(length(root.branches)+1)), (offset/branch_length,y0+height*i/(length(root.branches)+1))) for (i,(by0,by1)) ∈ enumerate(branch_root_loc)
                    ]..., connector_style...)]
                end...,
                
                if isempty(root.branches)
                    # draw end-cap
                    [circle(offset/total_length, y0+0.5*height, 0.5h*height)]
                else
                    []
                end...,
                
            ), 
            
            # draw sub-branches
            [
                # draw actual sub-branch
                (context(x0-branch_total_lengths[i]/total_length, branch_ys[i], branch_total_lengths[i]/total_length, branch_heights[i]), branch_drawings[i][2:end]...) for i ∈ eachindex(branch_drawings)
            ]...,
            
            # draw synapses
            [
                (context(), arc(x0+(offset+i-1+0.5)*lw, y0, 0.4*lw, π, 2π), fill(lc)) for (i,lc) ∈ enumerate(root.SC)
            ]...,
            
            
            style...
        )
    return drawing, total_length, total_branches, y0, y0+height
end

function plotDendrite(args...;canvas=nothing, kwargs...)
    drawing, total_length, total_branches, _,_ = _draw_branch(args...; kwargs...)
    composed_drawing = compose(context(), drawing)
    if canvas != nothing
        draw(canvas, composed_drawing)
    end
    return (drawing=composed_drawing, width=total_length, height=total_branches)
end

end
