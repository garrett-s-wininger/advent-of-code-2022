# Advent of Code Day 1 - Calorie Counting

This folder contains the attempted solution to the first of the 2022 Advent of Code 
challenges. For this, we want to take a text file containing groupings of calorie 
counts and print the largest total that is available in the file. The 
implementation here is based on standard C, using POSIX functionality for line 
parsing and GNU Autotools for the build system.

In order to run the program, the following invocation can be used:

	autoreconf -i
	./configure
	make clean
	make
	./main input

To successfully run the above, you'll additionally need autotools, make, and 
a C compiler on your system.

