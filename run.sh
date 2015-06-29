#!/bin/sh
make veryclean
gfortran -c Varidefine.f90
#gfortran -c Getgrid.f90
#gfortran -c GetLayerNumber.f90
gfortran -c tempProfile.f90
#gfortran Varidefine.o GetGrid.o GetLayerNumber.o test1.f90 -o gridtest	
gfortran Varidefine.o tempProfile.o test1.f90 -o temptest
./temptest
