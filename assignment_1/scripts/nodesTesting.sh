#!/usr/bin/env bash
CurrentTime=$(date +"%Y-%m-%d_%H-%M-%S")

OUTFILE="nodes_results_$CurrentTime.csv"
echo "Program,Arg1,Arg2,Time,UserTime,SysTime,CPU,PeakMemoryKB,MajorFaults,MinorFaults,VoluntaryCS,InvoluntaryCS" > $OUTFILE

UNIFORMNODEPROGRAMS=(
"build-CMA-V2/regular_uniform_nodes"
"build-CMA-V2/overloaded_uniform_nodes"
)

for prog in "${UNIFORMNODEPROGRAMS[@]}"; do
    echo "Running $prog..."
    arg2=1200
    for arg1 in 1400; do

        for i in {1}; do
            echo "Running $prog with argument $arg1..."
            # --- TIME -v ---
            TIMELOG=$(mktemp)
            /usr/bin/time -v "$prog" "$arg1" "$arg2" 1>/dev/null 2>"$TIMELOG"

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
            echo "$(basename $prog),$arg1,$arg2,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
        arg2=$((arg2 * 2))
    done
done

echo "Done. Results saved to $OUTFILE."