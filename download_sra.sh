#!/usr/bin/env bash
function get_from_link {
    {
	read -u 5 -r fn;
	read -u 5 -r link;
    } 5< <(python "$SCRIPT_DIR/get_run_link.py" "$1")
    wget -O "$fn" "$link"
    fasterq-dump "./$fn" -e "$jobs"
    #fasterq-dump <(wget -O - "$(python get_run_link.py "$1")")
}
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
jobs=1
declare -a accs
while [ "$#" -gt 0 ]; do
    case "$1" in
	"--jobs" | "-j")
	    shift;
	    jobs="$1"
	    ;;
	*)	    
	    accs+=("$1")
	    # >&2 echo "Unrecognized argument $1"
	    # exit 1
	    ;;
    esac
    shift
done
export jobs
for acc in "${accs[@]}"; do
    echo "$acc"
    get_from_link "$acc"
done
if [ "${#accs[@]}" -eq 0 ]; then
    while IFS= read -r line; do
	echo "$line"
	get_from_link "$line"
    done    
fi
