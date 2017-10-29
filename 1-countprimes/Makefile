all: countprimes sequential

countprimes: countprimes.adb
	gnatmake countprimes.adb
	
sequential: sequential.adb
	gnatmake sequential.adb

test: countprimes
	./countprimes 1000000 3 200000
	make clean

clean:
	-rm -f *~ *# *.o *.ali countprimes sequential

