Quick docs, still wip XD
# DEAIED
Is a neural tework simulation build by @n0o0b090lv and it runs spiders called Terries as they try to reach unreachable goal
# Setup
To run this, currently
1. Clone repo locally
2. Open godot and choose import
3. Select the folder you downloaded
4. Run
# Instructions
## Basic movement
WASD - Move<br>
Shift - faster move<br>
Scroll wheel - zoom in/out<br>
Right click - lock camera to center of screen/ unlock<br>
Esc - Unlocks camera<br>
Click - Use tool (for now only grab)<br>
## Tabs
There are currently 6 tabs each hosing somthing difrent so here is quick rundown
### Main
Main is tab for staring and running/saving simulation
1. Start training - resets all data and randomize spawn spiders
2. Pause - pauses timer for you to mess around the spiders
3. End batch - quickly ends the bach usefull if you set time to big
4. Save - Saves brain, if name taken it will create new one using curent time, also outputs errors if any for dual purpose :DD
5. Open saves - opens explorer to view all saved files, here you can drag in or copy out .ai files (they are in saves folder)
6. Refresh saves - Refreshes save list when files have been pdated
7. Loads spider, reseting curent training
### Simulation
There are many parameters about the simulation and enviroment
1. Round timer - how long is each round
2. Spider timer - how many spiders are per batch (sadly godot has only 31 collision layers so max this is 31)
3. Spider batches - how many spider batches there are
4. Keep best - does the simulation keep the best spider
5. Mutation probablity - how likely is for neuron to change some of its values
6. Mutation amount - how much the neuron is changed
### Rewards
These are spiders rewards, aka PAIN and BLISS
1. Ground height - how hig the ai has to be not to get pain (indicated by beeing red)
2. Ground pain - how much ai is beeing hurt when it's bellow ground height
3. Random goal - randomizes goal position (leave is off as current ai can barly think of way to get foward XD)
4. Goal distance - the distance from spider to goal
5. Goal reward - the reward for getting the goal
6. Goal distance reward - the reward for going towards the goal
### Spider
These are the parameters that determine the smartness of ai<br>
(only is set when new simulation is run)<br>
(input neurons are 51 + memory neurons)<br>
(output neurons are 24 + memory neurons)
1. Ai hidden layers - how many hidden layers ai has
2. Neurons per layer - how many neurons ai has per hidden layer
3. Memory neurons - how many neurons that get rembered each loop, aka output to input
### Stats
All it does is show stats...
### Tools
WIP
# How this works?
Terry is an ai agent aka it has neurons that each has simple multiplication addition and clamping funtion to each, nothing special? well when you have multiple then the magic begins.<br>
Each generation the Terry is ranked based on performance and the better the more likely it has to suriv and reproduce (it reproduces asexualy) and each generation it mutates a bit, aka some of it's brain neurons get tweaked a bit, and so on and so foward till Terrry learns how to walk :DD<br>
For ranking it is a simple syste, it is a mix of how low terry was and how many goals and goals distance to him, in short he likes staying above the ground and walking towards goal :DD 
