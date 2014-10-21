Synthetic Generator for Attributes Based Network

This repository includes the synthetic network generator (ASG) code for our paper: Synthetic Generators for Cloning Social Network Data. Awrad Mohammed Ali, Hamid Alvari, Nima Hajibagheri, Kiran Lakkaraju, and Gita Sukthankar.

1)"undirect_synthetic_generator.m" file contains the main code for generating ASG network


2)"transformAttributes.m" file contains the code for normalizing the attributes.

3)"statistic.m" file contains the code for the fitness function used by the ASG generator

4)"tuneGA.m" file contains the code for genetic algorithm if the user prefers to use it as the tuning algorithm

5)"tuneAttributes.m" file contains the code for Particle swarm optimazation if the user prefers to use it as the tuning algorithm

6)"loadStats.m" file contains the code for loading the target statistics in file "targetStats.csv"

7)An example of how to run the generator is explained in "input.txt" file.

