#!/usr/bin/env bash
set -x
if which wget; then
    function download {
	if [ -t 1 ]; then
	    wget -O "$1" "$2"
	else
	    wget --progress=dot:giga -O "$1" "$2"
	fi
    }
elif which curl; then
    function download {
	curl -L -o "$1" "$2"
    }
else
    >&2 echo "wget or curl must be installed to use download_sra.sh"
    exit 1
fi
function get_from_link {
    {
	read -u 5 -r fn;
	read -u 5 -r link;
    } 5< <(python "$SCRIPT_DIR/get_run_link.py" "$1")
    download "$fn" "$link"
    if [ "$extract" = true ]; then
	fasterq-dump "./$fn" -e "$jobs"
	if [ "$do_remove" = true ]; then
	    rm "./$fn"
	fi
    fi
    #fasterq-dump <(wget -O - "$(python get_run_link.py "$1")")
}
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
jobs=1
do_remove=false
extract=true
declare -a accs
while [ "$#" -gt 0 ]; do
    case "$1" in
	"--jobs" | "-j")
	    shift;
	    jobs="$1"
	    ;;
	"--remove" | "-r")
	    do_remove=true
	    ;;
	"--no-extract" | "-X")
	    extract=false
	    ;;
	*)	    
	    accs+=("$1")
	    # >&2 echo "Unrecognized argument $1"
	    # exit 1
	    ;;
    esac
    shift
done
if [ "$jobs" -lt 0 ]; then
    >&2 echo "Invalid parallel job count $jobs."
    exit 1
fi
if [ "$jobs" -eq 0 ]; then
    if jobs="$(nproc)"; then
	:
    elif jobs="$(sysctl -n hw.ncpu)"; then
	:
    fi
fi
if [ -z "$jobs" ] || [ "$jobs" -eq 0 ]; then
    >&2 echo "Could not determine number of logical cores on system."
    exit 1      
fi
echo "jobs is $jobs"
export do_remove
export jobs
export extract
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
