# DE4Opti_Group11
DE4 Optimisation Group 11 - minimising cost for a skateboard

To run this optimisation formulation this is the software required:
* [Matlab R2016b or above](https://uk.mathworks.com/products/matlab.html?requestedDomain=)
* [Global Optimisation Toolbox](https://uk.mathworks.com/products/global-optimization.html) 


# Subsystem 1: Deck 
This branch contains:
* Main Code file - **Deck_Subsystem.m**
* Linear regression model to find coefficients - **linearfunction.m**
* Non linear regression model - **nonlinearfunction.m**
* Optimiser - **optimisfunction.m**
* Data files - **Ply30.mat , Al30.mat, CF30.mat, ABS30.mat, PET30.mat, Input30.mat**

# Subsystem 2: Wheel
* Main Code file - **NewWheel.m**
* Polynomial fitting needs **polyfitn.m**
* Show polynomial model - **polyn2sym.m**
* Exeution time: 7s

# System
This branch combines all the files needed for both subsystem
Redundant trials of fitting models were removed
The minised costs of both subsystems were combined to calculate the total minimised cost
