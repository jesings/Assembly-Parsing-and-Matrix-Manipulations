all: matrix.o draw.o edgy.o prgrid.o bresenham.o manipulations.o parser.o
	gcc -o matrix -lgcc draw.o matrix.o edgy.o prgrid.o bresenham.o manipulations.o parser.o -lm
	./matrix
draw.o: draw.S
	gcc -c -g draw.S
matrix.o: matrix.S
	gcc -c -g matrix.S
edgy.o: edgy.S
	gcc -c -g edgy.S
bresenham.o: bresenham.S
	gcc -c -g bresenham.S
prgrid.o: prgrid.S
	gcc -c -g prgrid.S
manipulations.o:manipulations.S
	gcc -c -g manipulations.S
parser.o:parser.S
	gcc -c -g parser.S
