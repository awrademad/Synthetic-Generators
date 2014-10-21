function [Net,label] = synthetic_generator(numNodes,alpha,dh,numCommunities, relationTransition,numlinks,freq)
% Generate synthetic multi-link network (MLG) in paper "Synthetic Generator for Cloning Social Network Data"
%%%%%%%%%INPUT:%%%%%%%%%%%
% numNodes: the number of nodes in the network
% alpha: is a parameter that controls the number of links in the graph (between (0,1]);
% dh: the value for homophily choose between (0,1]
% numCommunities: the total number of communities in the network
%relationTransition: 2D matrix that hold the co-occurance of the links
%numlinks: the number of different links in the network
%freq: vector that hold the links frequencies in the network
%%%%%%%%OUTPUT%%%%%%%%%%%%
% Net: the network connectivity 3D matrix
% label: the node's label
%last update by Awrad Mohammed Ali 10-21-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = 0;
Net = zeros(numNodes,numNodes,numlinks);
label = [];
numAct=1;

while (i<numNodes)
    r = rand;
    if(i<=2)
        [Net,label] = addNode(Net, i, numCommunities,label,dh, relationTransition,numlinks,freq);
        i = i+1;
    else
        if (r <= alpha)
           Net = connectNode(Net,i,numCommunities,label,dh,numAct,relationTransition,numlinks,freq);
        else
            [Net,label] = addNode(Net, i, numCommunities,label,dh, relationTransition,numlinks,freq);
            i = i+1;
        end
    end
end
label = label';    

function [Net,label] = addNode(Net, i, numCommunities, label, dh,relationTransition,numlinks,freq)

v = i+1;
c = chooseNewNodeClass(numCommunities);      %choose community for the node

mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.
label(v) = c;
if v>1
    Cn = chooseClass(c, dh, numCommunities, label, v);
 Net = SFNWLink(Net, mlinks, Cn, v,label, relationTransition,numlinks,freq);
end

function [Net] = connectNode(Net,i,numCommunities,label,dh,numAct,relationTransition,numlinks,freq)

mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.
if length(label)<numAct
    numAct = length(label);
end

for j = 1: numAct
    if i>2
        v =  random('unid',i);   % randomly choose a node from G/ i is the current number of nodes
        c = label(v);
        Cn = chooseClass(c, dh , numCommunities,label,v);
       [Net] = SFNWLink(Net, mlinks, Cn, v,label,relationTransition,numlinks,freq);
    end
end


function  Cn = chooseClass(c,dh, numCommunities,label,v)
tmp =[];
while (isempty(tmp))
    r = rand;
    if (r >= dh )
        if (~isempty(find(label~=c)))
            ww = setdiff(1:numCommunities,c);
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

c = random('unid',numCommunities);


function [Net] = SFNWLink(Net, mlinks, Cn, v,label, relationTransition,numlinks,freq) %Scale-Free Network


nlabel= 1:numlinks;
z = eventChooser(nlabel,freq);    %choose the main link based on the links' frequencies
if z == 0                         %if no links were chosen, the main link is the link with the highest frequency
    [value, index] = max(freq);   
    z = index;
end

tranIndex = 1:size(relationTransition, 2);
tranProb = relationTransition(z, tranIndex);      %choose the secondary links

lp = eventChooser(nlabel, tranProb);

if lp == 0
    lp = z;                                % if no links chosen, chose the main link again (adding weights)
end

bondChances = 0.5;                         % control the desire to have secondary links (zero means always connect with other links if they are chosen)

tp = setdiff(1:length(label),v);
label2 = label(tp);
tmp = find(label2 == Cn);
L = length(tmp);   % save the number of nodes with label Cn

if (L < mlinks)
    mlinks = L;
end

sumlinks = sum(sum(Net(:,:,z)));                       

pos = v;
linkage = 0;

% generate mlinks for the given node
while linkage ~= mlinks
    t = ceil(rand * length(tmp)); 
    rnode = tp(tmp(t));
    randomN = rand;
    
    if (sumlinks == 0)
        Net(pos,rnode,z) = Net(pos,rnode,z) + 1;            %connect by the main link
        Net(rnode,pos,z) = Net(rnode,pos,z) + 1;
        if  randomN<bondChances
             Net(pos,rnode,z) = Net(pos,rnode,z) + 1;
             Net(rnode,pos,z) = Net(rnode,pos,z) + 1;
        else
          Net(pos,rnode,lp) = Net(pos,rnode,lp) + 1;     %connect by the secondary link                   
          Net(rnode,pos,lp) = Net(rnode,pos,lp) + 1;    
           
        end
       linkage = linkage +1;
    else                
        
         Net(pos,rnode,z) = Net(pos,rnode,z) + 1; 
         Net(rnode,pos,z) = Net(rnode,pos,z) + 1;
         
        if  randomN<bondChances
             Net(pos,rnode,z) = Net(pos,rnode,z) + 1;
             Net(rnode,pos,z) = Net(rnode,pos,z) + 1;
          
        else
          Net(pos,rnode,lp) = Net(pos,rnode,lp) + 1;                      
              Net(rnode,pos,lp) = Net(rnode,pos,lp) + 1;    
            
        end
         linkage = linkage + 1;   
    end
end




