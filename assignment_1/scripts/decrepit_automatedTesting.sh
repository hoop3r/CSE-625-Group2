#!/usr/bin/env bash
CurrentTime=$(date +"%Y-%m-%d_%H-%M-%S")

OUTFILE="results_$CurrentTime.csv"
echo "Program,Arg1,Arg2,Time,UserTime,SysTime,CPU,PeakMemoryKB,MajorFaults,MinorFaults,VoluntaryCS,InvoluntaryCS" > $OUTFILE

MATRIXPROGRAMS=("build-CMA-V1/regular_new" 
"build-CMA-V1/overloaded_new"
)

MEMORYSTRESSPROGRAMS=(
"build-CMA-V1/regular_memory_stress"
"build-CMA-V1/overloaded_memory_stress"
)

UNIFORMNODEPROGRAMS=(
"build-CMA-V1/regular_uniform_nodes"
"build-CMA-V1/overloaded_uniform_nodes"
)

LINKEDLISTPROGRAMS=(
"build-CMA-V1/regular_linked_list"
"build-CMA-V1/overloaded_linked_list"
)

for prog in "${MATRIXPROGRAMS[@]}"; do
    echo "Running $prog..."

    for arg in 10 20 40; do
        for i in {1..5}; do
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
            peak=$(grep "Maximum resident set size" "$TIMELOG" | awk '{print $6}')
            majflt=$(grep "Major (requiring I/O) page faults" "$TIMELOG" | awk '{print $6}')
            minflt=$(grep "Minor (reclaiming a frame) page faults" "$TIMELOG" | awk '{print $6}')
            vcs=$(grep "Voluntary context switches" "$TIMELOG" | awk '{print $5}')
            ivcs=$(grep "Involuntary context switches" "$TIMELOG" | awk '{print $5}')

            # --- WRITE ROW ---
            echo "$(basename $prog),$arg,$null,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
    done
done

for prog in "${MEMORYSTRESSPROGRAMS[@]}"; do
    echo "Running $prog..."

    for arg in 10 20 40; do
        for i in {1..5}; do
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
            peak=$(grep "Maximum resident set size" "$TIMELOG" | awk '{print $6}')
            majflt=$(grep "Major (requiring I/O) page faults" "$TIMELOG" | awk '{print $6}')
            minflt=$(grep "Minor (reclaiming a frame) page faults" "$TIMELOG" | awk '{print $6}')
            vcs=$(grep "Voluntary context switches" "$TIMELOG" | awk '{print $5}')
            ivcs=$(grep "Involuntary context switches" "$TIMELOG" | awk '{print $5}')

            # --- WRITE ROW ---
            echo "$(basename $prog),$arg,$null,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
    done
done

for prog in "${UNIFORMNODEPROGRAMS[@]}"; do
    echo "Running $prog..."
    arg2=100
    for arg1 in 25 50 100; do

        for i in {1..5}; do
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
            peak=$(grep "Maximum resident set size" "$TIMELOG" | awk '{print $6}')
            majflt=$(grep "Major (requiring I/O) page faults" "$TIMELOG" | awk '{print $6}')
            minflt=$(grep "Minor (reclaiming a frame) page faults" "$TIMELOG" | awk '{print $6}')
            vcs=$(grep "Voluntary context switches" "$TIMELOG" | awk '{print $5}')
            ivcs=$(grep "Involuntary context switches" "$TIMELOG" | awk '{print $5}')

            # --- WRITE ROW ---
            echo "$(basename $prog),$arg1,$arg2,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
        arg2=$((arg2 * 2))
    done
done

for prog in "${LINKEDLISTPROGRAMS[@]}"; do
    echo "Running $prog..."

    for arg in 10000 20000 40000; do
        for i in {1..5}; do

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
            peak=$(grep "Maximum resident set size" "$TIMELOG" | awk '{print $6}')
            majflt=$(grep "Major (requiring I/O) page faults" "$TIMELOG" | awk '{print $6}')
            minflt=$(grep "Minor (reclaiming a frame) page faults" "$TIMELOG" | awk '{print $6}')
            vcs=$(grep "Voluntary context switches" "$TIMELOG" | awk '{print $5}')
            ivcs=$(grep "Involuntary context switches" "$TIMELOG" | awk '{print $5}')

            # --- WRITE ROW ---
            echo "$(basename $prog),$arg,$null,$elapsed,$user,$sys,$cpu,$peak,$majflt,$minflt,$vcs,$ivcs" >> $OUTFILE
            rm "$TIMELOG"
        done
    done
done

echo "Done. Results saved to $OUTFILE."