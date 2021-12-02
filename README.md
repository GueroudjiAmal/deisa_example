# deisa_example
An example how to use deisa 
 ## Requirement :
- distributed repo : https://github.com/GueroudjiAmal/distributed

- the timedim should be the first poition in an array :
  exp : 
  array.shape = (x,y,z); where x in the max timesteps and 0 is the timedim.

- for the momemnt no way to control the worker memory 
  I'll se how to manage that later, for the moment we have to pay attention to the size of the data we sent to the workers at once

## Done with deisa plugin and deisa_distributed 
- No time loop in the analytics  
- Multiple arrays can be sent
- No metadata exchange
- Deisa plugin with a newer interface  
- Scatter with specified data key and a new keyword deisa  
- Deisa state in the scheduler to manage external mpi tasks 
- scatter implies the the transition processes 
