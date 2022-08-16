#!/usr/bin/env bash

PWD=`pwd`
PAR="${PWD}/../countprimes"
SEQ="${PWD}/../sequential"

N=(10000 100000 1000000 10000000)
T=(2 3 4 8)
DIV=(2 3 4 5 8 10 20)
TESTS=1
#TESTS=3
#TESTS=5

FILE=""

SEQTIME=0
PARTIME=0

function realpath
{
	echo $1 | sed 's/ /\\ /g'
}

if [[ ! -e $PAR || ! -e $SEQ ]]; then
	MY_PATH=`echo $PAR | sed 's/\(.*\)\/.*/\1/'`
	$(SHELL=/bin/sh make all -C ${MY_PATH})
fi

# Links
# 1) https://software.intel.com/en-us/articles/predicting-and-measuring-parallel-performance
# 2) http://www.d.umn.edu/~tkwon/course/5315/HW/MultiprocessorLaws.pdf
function compute_speedup()
{
	if [[ $SEQTIME = 0 || $PARTIME = 0 ]]; then
		echo "something wrong!"
		exit 1;
	fi

	SPEEDUP=$(awk "BEGIN {printf \"%.6f\", ${SEQTIME}/${PARTIME}}")
	printf "Speedup: $SPEEDUP \n"

	EFFICIENCY=$(awk "BEGIN {printf \"%.6f\", ${SPEEDUP}/${3}}")
	printf "Efficiency: $EFFICIENCY \n"

	PERCENT=$(awk "BEGIN {printf \"%.6f\", (1 - (${PARTIME}/${SEQTIME}))*100}")
	echo "PARALLEL is ${PERCENT}% faster than SEQUENTIAL!"

	printf "$SPEEDUP\t$EFFICIENCY\t$PERCENT\n" >> ${FILE}
}

function run()
{
	i=0
	temp=0
	sum=0
	
	if [[ $# = 1 ]]; then
		while [ $i -lt ${TESTS} ];
		do
			temp=$(SHELL=/bin/sh ${SEQ} $1 | grep RunTime | awk '{ printf $3 " "}')
			sum=`echo $sum + $temp | bc`
			i=$((i+1))
		done
		sum=$(awk "BEGIN {printf \"%.6f\", ${sum}/${TESTS}}")
		SEQTIME=${sum}
	elif [[ $# = 3 ]]; then
		while [ $i -lt ${TESTS} ];
		do
			temp=$(SHELL=/bin/sh ${PAR} $1 $2 $3 | grep RunTime | awk '{ printf $3 " "}')
			sum=`echo $sum + $temp | bc`
			i=$((i+1))
		done
		sum=$(awk "BEGIN {printf \"%.6f\", ${sum}/${TESTS}}")
		PARTIME=${sum}
	else
		echo "wrong!!"
		exit 1;
	fi
}


for n in ${N[@]};
do
	FILE="result_${n}.dat"
	printf "#T\tS\tRuntime\t\tSpeedup\t\tEfficiency\tPercent\n" > ${FILE}

	run ${n}	# run sequential
	printf "1\t${n}\t${SEQTIME}\t1.0\t\t1.0\t\t0\n" >> ${FILE}

	for t in ${T[@]};
	do
		for d in ${DIV[@]};
		do
			s=$((n / d))
			#sleep 2;
			run $n $t $s
			printf "N=$n T=$t S=$s \n"
			printf "Sequential: ${SEQTIME} \n"
			printf "Parallel: ${PARTIME} \n"
			printf "${t}\t${s}\t${PARTIME}\t" >> ${FILE}
			compute_speedup $SEQTIME $PARTIME $t $n;
			echo "=============================="
		done
	done
done


$(SHELL=/bin/sh make clean -C ..)
