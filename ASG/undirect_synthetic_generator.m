function [Net,Attributes,label] = undirect_synthetic_generator(numNodes,alpha,dh,numCommunities,attNumber, targetStats,fs)
% Generate synthetic network using ASG generator described in "Synthetic
% Generator for Cloning Social Network Data".
%%%%%%%%%INPUT:%%%%%%%%%%%
% numNodes: the number of nodes in the network
% alpha: is a parameter that controls the number of links in the graph (between (0,1]); 
% fs: feature similarity parameter
% dh: the value for homophily choose between (0,1]
% numCommunities: the total number of communities in the network
%attNumber: the number of features that each node has
%targetStats: the targeted statistic file
%
%%%%%%%%OUTPUT%%%%%%%%%%%%
% Net: the network connectivity matrix
% Attributes: the features asscoiated with each node
% label: the node's label
% Updated by Awrad Mohammed Ali    10/25/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = 0;
Net = zeros(numNodes,numNodes,'single');
label = [];
numAct=1;

while (i<numNodes)
    r = rand;
    if(i<=2)
        [Net,label] = addNode(Net, i, numCommunities,label,dh, numNodes);
        i = i+1;
    else
        if (r <= alpha)
            Net = connectNode(Net,i,numCommunities,label,dh,numAct, numNodes);
        else
            [Net,label] = addNode(Net, i, numCommunities,label,dh, numNodes);
            i = i+1;
        end
    end
end
label = label';                  
Attributes = zeros(numNodes,attNumber);
for i =1:numNodes
    Attributes  = genAttributes(i, numCommunities, attNumber, Attributes,label);
end
Attributes = tuneAttributes(Attributes, targetStats);        % use the PSO algorithm as the tuning algorithm

%Attributes = tuneGA(Attributes, targetStats);               % use the GA as the tuning algorithm

Net = filter_connections(Net, Attributes,fs);                   % connect nodes based on their feature similarities


function [Net,label] = addNode(Net, i, numCommunities, label, dh, gNumNodes)


v = i+1;
c = chooseNewNodeClass(numCommunities);      %chose community for the node
mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.
label(v) = c;
if v>1
 dhn = i*0.05;                       % dynamic homophily
    
    if dhn > dh
        dhn = dh;
    end
    Cn = chooseClass(c, dhn, numCommunities, label, v);
    Net = SFNW(Net, mlinks, Cn, v, label);    
end

function Net = connectNode(Net,i,numCommunities,label,dh,numAct, gNumNodes)

mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.
if length(label)<numAct
    numAct = length(label);
end

for j = 1: numAct
    if i>2
        v =  random('unid',i);   % randomly choose a node from G/ i is the current number of nodes
        c = label(v);
         dhn = i*0.05;
        if dhn > dh
            dhn = dh;
        end
        Cn = chooseClass(c, dhn , numCommunities,label,v);   %choose community for the node
        Net = SFNW(Net, mlinks,Cn, v,label);
    end 
end


function Attributes = genAttributes(v,numCommunities,attNumber,Attributes,label)
for i =1:attNumber
    p = (1 + (label(v)-1))/(1+numCommunities);
    w = binornd(attNumber-1,p); % generate binomial random number
    Attributes(v,w+1) = floor(rand * 9);    
   
end

function  Cn = chooseClass(c,dh, numCommunities,label,v)                                                  

tmp =[];
while (isempty(tmp))
    r = rand;
    if (r >= dh )
        if (~isempty(find(label~=c)))
            ww = setdiff(1:numCommunities,c);            %return other values of numLables that is not equal to c.
            while (isempty(tmp))
                w = random('unid',length(ww));
                tmp = find(label == ww(w));
            end
            Cn = ww(w);
        else
            Cn = c;
            l = setdiff(1:length(label),v);
            tmp = find(label(l) == Cn);
        end
    else
        Cn = c;
        l = setdiff(1:length(label),v);
        tmp = find(label(l) == Cn);
    end
end

function c = chooseNewNodeClass(numCommunities)
 
c = random('unid',numCommunities);                              %choose randomly a community form the poll of communities

function Net = SFNW(Net, mlinks, Cn, v,label) %Scale-Free Network
% Cn is the label of the node to be connected
tp = setdiff(1:length(label),v);
label2 = label(tp);
tmp = find(label2 == Cn);
L = length(tmp);   % save the number of nodes with label Cn

if (L < mlinks)
    mlinks = L;
end

sumlinks = sum(sum(Net));

pos = v;
linkage = 0;

% generate mlinks for the given node
while linkage ~= mlinks
    t = ceil(rand * length(tmp)); % the index of the chosen node
    rnode = tp(tmp(t));
    deg = sum(Net(:,rnode))*2;
    rlink = rand * 1;
    r=rand;
    if (sumlinks == 0)
        % generate undirected links
        if r >= 0.1
            Net(pos,rnode) = Net(pos,rnode) + 1;
            Net(rnode,pos) = Net(rnode,pos) + 1;
        else
            break;
        end
        linkage = linkage +1;

    elseif (rlink < deg/sumlinks) || (sum(sum(Net(:,tp(tmp))))*2 == 0) 
    % generate undirected links
        if r >= 0.1
            Net(pos,rnode) = Net(pos,rnode) + 1;
            Net(rnode,pos) = Net(rnode,pos) + 1;
        else
            break;
        end
        linkage = linkage +1;

    end
end


function [Net]=filter_connections(Net, Attributes,fs)
    numNodes = size(Net, 1);
    compatibilityScores = mandist(Attributes(:,:), Attributes(:, :)');
    for i = 1:numNodes
        bestMatch = min(compatibilityScores(i, 1:end ~= i));   %connect node to the most similar node
        tempCompare = compatibilityScores(i, :) - bestMatch;
        matches = setdiff(find(compatibilityScores(i, :)), find(tempCompare));
        for j = 1:length(matches)
            if rand <= fs
                Net(i, matches(j)) = Net(i, matches(j)) + 1;
            end
        end
    end
