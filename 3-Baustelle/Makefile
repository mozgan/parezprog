all: workplace

workplace: workplace.adb
	gnatmake workplace.adb

test: workplace
	./workplace 5 2 3 3
	make clean

clean:
	-rm -f *~ *# *.o *.ali workplace

