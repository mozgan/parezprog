all: countprimes

countprimes: countprimes.adb
	gnatmake countprimes.adb
	
test: countprimes
	./countprimes 10_000_000 4 1000_000 2000
	make clean

clean:
	-rm -f *~ *# *.o *.ali countprimes

