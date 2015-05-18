CoherentModel_Fortran runs UWBRAD virtual mission with coherent model in fortran.
To get access to the mission,please go to
https://github.com/YunaDuan/CoherentModel_Fortran.git
Collaborators: Yuna Duan; Michael Durand
-Yuna Duan-May 7th, 2015

Files:
1.CoherentTb.f90: The function using coherent model to generate brightness temperature

2.VariDefine.f90: The common module used to define variables

3.maintest.f90: The main program to test the performance of model with summit data

4.makefile: Makefile for GUN to compile the project

5.dat:
-rho.dat: One realization of summit density for coherent model testing
-T.dat: Temperature profile of summit
-z.dat: Corresponding depth of density and temperature

6.Matlab_Crosscheck
-coherent_model.m: The original Matlab version of coherent model
-Input_param3.mat: The .mat version of summit profile

Workflow:
A compiled executable of maintest is listed as maintest, I am not sure if it will work on Win platform.If it’s working, just run the maintest to check the result; If not, please compile the maintest.f90.
The Tb will be displayed on the screen.

For Matlab_crosscheck, the Coherent Model function is changed to a script to run the whole process. Compare the Tb_H,Tb_V,Tb with the result of Fortran program.


