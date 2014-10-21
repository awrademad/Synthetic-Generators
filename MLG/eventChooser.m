function event = eventChooser(events, probabilities)           %the function is used to choose between the links

    n = length(events);
    if(n == 0)
        event = 0;
        return;
    end
    if(n == 1)
        event = events(n);
        return;
    end

    options = zeros(1, n);
    for i = 1:n
       r = rand;
       if r < probabilities(i) && probabilities(i)~=1 
           options(i) = 1;
       end
    end
    newEvents = find(options);
    event = eventChooser(events(newEvents), probabilities(newEvents));

end