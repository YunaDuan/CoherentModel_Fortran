#!/bin/sh
make veryclean
gfortran -c Varidefine.f90
gfortran -c CoherentTb.f90
gfortran Varidefine.o CoherentTb.o maintest.f90 -o maintest	





