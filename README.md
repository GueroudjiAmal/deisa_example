# Dask-Enabled In Situ Analytics
This repository contains an example on how deisa can be used. 

## Requirement :
- [Deisa PDI plugin](https://github.com/GueroudjiAmal/deisa) 
- [Dask Distributed Deisa version repo](https://github.com/GueroudjiAmal/distributed)

## How it works ?

A simulation can be instrumented in PDI to make its internal data available for **_DEISA_**. The plugin retrieves it, creates corresponding keys, and sends it to Dask workers. 

Internally, a **_DEISA Bridge_** is created per MPI process. Once a piece of data is shared with PDI, the Bridge sends it to a worker that has been chosen in a round-robin fashion. 

**_DEISA_** python library implements a **_DEISA Adaptor_**. This component is used from the Dask client-side to create Dask arrays describing the data generated by the simulation. The **_DEISA Adaptor_** waits for an array descriptor to be sent from the **_DEISA Bridge_** in MPI rank 0. This descriptor is a dictionary with data names as keys and a dictionary containing the sizes, dimensions, and chunk sizes, as values. 
The **_DEISA Adaptor_** uses this information to create `deisa_arrays` object. A Dask array can be retreived by using the square brackets operator `[]`.

Contracts have been added to **_DEISA_**. 

## Files :
- simulation.c : is a toy example of a C simulation code, here we have used heat 2D from [PDI examples](https://pdi.dev/master/PDI_example.html).
- simulation.yml :  is the PDI configuration code. 
- dask-interface.py : contains **_DEISA_** python libaray (Bridge and Adaptor classes).
- Derivative.py containts an example of a python script for analytics. It it run is the Dask Client.
- prescript.py creates a file Config.yml that contains simulation configuration such as the size of data, the number of timesteps and the domain decomposition.
- Launcher.sh and Script.sh can be used to launch the simulation and Dask cluster in [Ruche](https://mesocentre.pages.centralesupelec.fr/user_doc/)
 
