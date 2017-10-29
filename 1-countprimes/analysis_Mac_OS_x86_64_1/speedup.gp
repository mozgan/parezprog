
set terminal pdf enhanced font "Helvetica, 10" size 7,4

set xlabel "Number of cores"
#set xtics 0, 1 rotate
set offset 0.1, 0.1

set ylabel "Speedup (Seq. Time / Parallel Time)"
set ytics nomirror tc lt 0.1
set offset 0.1, 0.1

set key vert left top Left

set xrange [1:8]
set yrange [0:4]

set grid

# speedup_10000.dat
outputfile = 'speedup_10000.pdf'
inputfile = 'result_10000.dat'
set output outputfile
set title sprintf('N = 10\_000')

plot \
    "<awk '{if($1 == 1){print $1,$4}}' $1" . inputfile w p t 'Sequential', \
    "<awk '{if($2 == 5000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 5\_000', \
    "<awk '{if($2 == 3333){print $1,$4}}' $1" . inputfile w lp t 'Slice: 3\_333', \
    "<awk '{if($2 == 2500){print $1,$4}}' $1" . inputfile w lp t 'Slice: 2\_500', \
    "<awk '{if($2 == 2000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 2\_000', \
    "<awk '{if($2 == 1250){print $1,$4}}' $1" . inputfile w lp t 'Slice: 1\_250', \
    "<awk '{if($2 == 1000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 1\_000', \
    "<awk '{if($2 == 500){print $1,$4}}' $1" . inputfile w lp t 'Slice: 500'


# speedup_100000.dat
outputfile = 'speedup_100000.pdf'
inputfile = 'result_100000.dat'
set output outputfile
set title sprintf('N = 100\_000')

plot \
    "<awk '{if($1 == 1){print $1,$4}}' $1" . inputfile w p t 'Sequential', \
    "<awk '{if($2 == 50000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 50\_000', \
    "<awk '{if($2 == 33333){print $1,$4}}' $1" . inputfile w lp t 'Slice: 33\_333', \
    "<awk '{if($2 == 25000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 25\_000', \
    "<awk '{if($2 == 20000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 20\_000', \
    "<awk '{if($2 == 12500){print $1,$4}}' $1" . inputfile w lp t 'Slice: 12\_500', \
    "<awk '{if($2 == 10000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 10\_000', \
    "<awk '{if($2 == 5000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 5\_000'


# speedup_1000000.dat
outputfile = 'speedup_1000000.pdf'
inputfile = 'result_1000000.dat'
set output outputfile
set title sprintf('N = 1\_000\_000')

plot \
    "<awk '{if($1 == 1){print $1,$4}}' $1" . inputfile w p t 'Sequential', \
    "<awk '{if($2 == 500000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 500\_000', \
    "<awk '{if($2 == 333333){print $1,$4}}' $1" . inputfile w lp t 'Slice: 333\_333', \
    "<awk '{if($2 == 250000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 250\_000', \
    "<awk '{if($2 == 200000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 200\_000', \
    "<awk '{if($2 == 125000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 125\_000', \
    "<awk '{if($2 == 100000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 100\_000', \
    "<awk '{if($2 == 50000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 50\_000'


# speedup_10000000.dat
outputfile = 'speedup_10000000.pdf'
inputfile = 'result_10000000.dat'
set output outputfile
set title sprintf('N = 10\_000\_000')

plot \
    "<awk '{if($1 == 1){print $1,$4}}' $1" . inputfile w p t 'Sequential', \
    "<awk '{if($2 == 5000000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 5\_000\_000', \
    "<awk '{if($2 == 3333333){print $1,$4}}' $1" . inputfile w lp t 'Slice: 3\_333\_333', \
    "<awk '{if($2 == 2500000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 2\_500\_000', \
    "<awk '{if($2 == 2000000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 2\_000\_000', \
    "<awk '{if($2 == 1250000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 1\_250\_000', \
    "<awk '{if($2 == 1000000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 1\_000\_000', \
    "<awk '{if($2 == 500000){print $1,$4}}' $1" . inputfile w lp t 'Slice: 500\_000'


