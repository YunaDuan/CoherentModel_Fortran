CoherentModel_Fortran runs UWBRAD virtual mission with coherent model in fortran.
To get access to the mission,please go to
https://github.com/YunaDuan/CoherentModel_Fortran.git
Collaborators: Yuna Duan; Michael Durand
-Yuna Duan-May 7th, 2015

==========================================================================
Files:
1.CoherentTb.f90: The function using coherent model to generate brightness temperature

2.VariDefine.f90: The common module used to define variables

3.GetLayerNum.f90: The subroutine to calculate the number of layers in the
coherent model grid setting

4.GetGrid.f90: The subroutine to get the depth of each layer in the grid

5.tempProfile.f90: The subroutine to calculate temperature profile by Robin
Model. 

6.DensityRealization.f90: The subroutine to generate density profile with
Gaussian exponentially decreased random noise

7.WriteOutput.f90: The subroutine to write coherent model simulated 
brightness temperature in txt file for future process

8.makefile: Makefile for GUN to compile the project

9.dat:
-rho.dat: One realization of summit density for coherent model testing
-T.dat: Temperature profile of summit
-z.dat: Corresponding depth of density and temperature

10.lib:
-libopenblas.a/libopenblas_haswellp-r0.2.14.a: External library OpenBLAS for high performance matrix computation

11.Matlab_Crosscheck
-coherent_model.m: The original Matlab version of coherent model
-Input_param3.mat: The .mat version of summit profile

==========================================================================
Workflow:
1. Input: Four ground information, Icesheet thickness H, accumulation rate M,geothermal heatflux G and surface temperature Ts ,are required as input.

2. Put the input under dat folder in txt/dat/csv format.

3. Use make file to compile the program named RunCoherentModel.f90, an executable RunCoherentModel will be generated.

4. Run the RunCoherentModel and the brightness temperature will be stored under folder Runs. Each profile is composed of 12 rows and 3 columns for 12 frequency and 3 incidence angle.
  
