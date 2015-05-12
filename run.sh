#!/bin/sh
gfortran -c GetCMInput.f90
gfortran GetCMInput.o maintest.f90 -o test2.out
./test2.out	
