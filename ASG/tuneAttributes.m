function[Attributes]=tuneAttributes(Attributes, targetStats)
%PSO algorithm
%Initialization
alpha = 0.8;
globalC = 2;
individualC = 2;
nagents = 30;
population = zeros(size(Attributes,1), size(Attributes,2), nagents);
velocity = zeros(size(Attributes,1), size(Attributes,2), nagents);
individualBest = zeros(size(Attributes,1), size(Attributes,2), nagents);
individualBestFitness = zeros(nagents);
globalBest = zeros(size(Attributes,1), size(Attributes,2));
globalBestFitness = 0;

for i=1:nagents   % the number of agents is 30
    population(:, :, i) =  floor(rand(size(Attributes,1), size(Attributes,2)) * 9);
    individualBest(:, :, i) = population(:, :, i);
    [individualBestFitness(i), s] = statistic(individualBest(:, :, i), targetStats);
end

globalBest = individualBest(:, :, 1);
individualBestFitness(1);

 for generation=1:200      % 200 maximum number of iteration

    for agent=1:nagents
       velocity(:,:,agent)=alpha .* velocity(:, :, agent) + individualC .* rand .* (individualBest(:, :, i)-population(:, :, agent))+ globalC .* rand .* (globalBest(:, :)-population(:, :, agent) );
       population(:, :, agent) = population(:, :, agent) + velocity(:, :, agent);
        
       [ifitness, s] = statistic(population(:, :, agent), targetStats);
        if ifitness > individualBestFitness(agent)
            individualBest(:, :, agent) = population(:, :, agent);
            individualBestFitness(agent) = ifitness;
            if ifitness > globalBestFitness
                globalBest = population(:, :, agent);
                globalBestFitness = ifitness;
            end
        end
    end  

end
Attributes = globalBest;
end

