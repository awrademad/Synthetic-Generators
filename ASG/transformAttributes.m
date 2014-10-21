function[NewAttributes]=transformAttributes(Attributes, TargetMean, TargetStd)  %shifting and normalizing the attributes
    Attr = Attributes - 4;
    NewAttributes = zeros(size(Attributes, 1), size(Attributes, 2));
    nnodes = size(NewAttributes, 1);
    for nodes = 1:nnodes
        NewAttributes(nodes, :) = Attr(nodes, :) .* TargetStd + TargetMean;     % following a z distribution 
    end
end