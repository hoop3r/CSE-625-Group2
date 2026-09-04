#!/usr/bin/env bash
CurrentTime=$(date +"%Y-%m-%d_%H-%M-%S")

OUTFILE="memory_stress_results_$CurrentTime.csv"
echo "Program,Arg1,Arg2,Time,UserTime,SysTime,CPU,PeakMemoryKB,MajorFaults,MinorFaults,VoluntaryCS,InvoluntaryCS" > $OUTFILE

MEMORYSTRESSPROGRAMS=(
"build-CMA-V2/regular_memory_stress"
"build-CMA-V2/overloaded_memory_stress"
)

for prog in "${MEMORYSTRESSPROGRAMS[@]}"; do
    echo "Running $prog..."

    for arg in 500; do
        for i in {1}; do
            echo "Running $prog with argument $arg..."

            # --- TIME -v ---
            TIMELOG=$(mktemp)
            /usr/bin/time -v "$prog" "$arg" 1>/dev/null 2>"$TIMELOG"

            elapsed=$(grep "Elapsed (wall clock) time" "$TIMELOG" | awk '{print $8}')
            user=$(grep "User time" "$TIMELOG" | awk '{print $4}')
            sys=$(grep "System time" "$TIMELOG" | awk '{print $4}')
            cpu=$(awk -v u="$user" -v s="$sys" -v e="$(echo "$elapsed" | awk -F: '{
                        if (NF == 3)
                            printf "%.6f", ($1 * 3600) + ($2 * 60) + $3;
                        else
                            printf "%.6f", ($1 * 60) + $2;
                    }' )" 'BEGIN { printf "%.3f", ((u+s)/e)*100 }')
            peak=$(grep "Maximum resident set size" "$TIMELOG" | awk '{print $NF}')
            majflt=$(grep "Major (requiring I/O) page faults" "$TIMELOG" | awk '{print $NF}')
            minflt=$(grep "Minor (reclaiming a frame) page faults" "$TIMELOG" | awk '{print $NF}')
            vcs=$(grep "Voluntary context switches" "$TIMELOG" | awk '{print $NF}')
            ivcs=$(grep "Involuntary context switches" "$TIMELOG" | awk '{print $NF}')

            # --- WRITE ROW ---
            echo "$(basename $prog),$arg,$null,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
    done
done

echo "Done. Results saved to $OUTFILE."