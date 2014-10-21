function[Attributes]=tuneGA(Attributes, targetStats)
    nagents = 30;
    population = zeros(size(Attributes,1), size(Attributes,2), nagents);
    populationFitness = zeros(1, nagents);

    for i=1:nagents   % the number of agents is 30
        population(:, :, i) =  floor(rand(size(Attributes,1), size(Attributes,2)) * 9);
        [populationFitness(i), s] = statistic(population(:, :, i), targetStats);

    end

    for generation = 1:200    
        for i=1:nagents
            if rand < 0.5                                               
                parent1 = selection(population, targetStats);
                parent2 = selection(population, targetStats);
                [child1,child2]= xover(parent1, parent2);
                [childa]= mutation(child1);
                [childb]= mutation(child2);
                [childa_fitness, s]= statistic(childa, targetStats);    % calculate the fitness for the new children
                [childb_fitness, s]= statistic(childb, targetStats);
                if populationFitness(i)< childa_fitness 
                    population(:, :, i) = childa;
                    populationFitness(i) = childa_fitness;
                elseif populationFitness(i)< childb_fitness
                    population(:, :, i) = childb;
                    populationFitness(i) = childb_fitness;
                end
            end 
        end
        
    end
    
    [best, index] = max(populationFitness);
    x = index;
    b = best;
    Attributes = population(:, :, index);
end


function[best]=selection(population, targetStats)
    tournament =2;
    randIndex = randi(size(population, 3));
    best_parent = population(:, :, randIndex);       %select random parents   ; Tournament size is 2
    [fitness_best_parent, s] = statistic(best_parent, targetStats);
    
    for agent=1:tournament
        x2 = population(:, :, randi(size(population, 3)));
        [fitness_x2, s] = statistic(x2, targetStats);
        if fitness_x2 > fitness_best_parent
            best_parent = x2;
        end
    end 
    best = best_parent;
end

function[child1,child2]= xover(parent1, parent2)
    xover_rate = 0.5;
    child1 = zeros(size(parent1, 1), size(parent1, 2));
    child2 = zeros(size(parent2, 1), size(parent2, 2));

    for n=1:size(parent1, 1)
       if rand < xover_rate
            child1(n,:) = parent1(n,:);
            child2(n,:) = parent2(n,:);
       else
            child1(n,:) = parent2(n,:);
            child2(n,:) = parent1(n,:);
       end
    end
end



function[child]= mutation(child)
    mutationStep = ((-1*ones(size(child, 1), size(child, 2))).^randi(100, size(child, 1), size(child, 2))) .* rand(size(child, 1), size(child, 2));

    mutation_rate = 0.5;
   for n=1:size(child, 1)
    if rand < mutation_rate
        child(n,:) = child(n,:) + mutationStep(n,:);
        child(child(:, :) < 0) = 0;
        child(child(:, :) > 8) = 8;
    end
   end
end



  