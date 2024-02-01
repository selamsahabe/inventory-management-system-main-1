#!/usr/bin/env bash
# wait-for-it.sh

# Usage: ./wait-for-it.sh host:port [-- command args]
#   -h|--help: Displays help information

TIMEOUT=40
WAIT_INTERVAL=2
QUIET=0

echoerr() {
    if [ "$QUIET" -eq 0 ]; then echo "$@" 1>&2; fi
}

usage() {
    exitcode="$1"
    cat << USAGE >&2
Usage:
    $cmdname host:port [-t timeout] [-- command args]
    -q | --quiet                        Do not output any status messages
    -t TIMEOUT | --timeout=timeout      Timeout in seconds, default 15
    -h | --help                         Show this help
    -- COMMAND ARGS                     Execute command with args after the test finishes
USAGE
    exit "$exitcode"
}

wait_for() {
    for i in `seq $TIMEOUT` ; do
        nc -z "$HOST" "$PORT" > /dev/null 2>&1

        result=$?
        if [ $result -eq 0 ] ; then
            if [ $# -gt 0 ] ; then
                exec "$@"
            fi
            exit 0
        fi
        sleep $WAIT_INTERVAL
    done
    echo "Operation timed out" >&2
    exit 1
}

while [ $# -gt 0 ]
do
    case "$1" in
        -q | --quiet)
        QUIET=1
        shift 1
        ;;
        -t)
        TIMEOUT="$2"
        if [ "$TIMEOUT" = "" ]; then break; fi
        shift 2
        ;;
        --timeout=*)
        TIMEOUT="${1#*=}"
        shift 1
        ;;
        --help)
        usage 0
        ;;
        --)
        shift
        wait_for "$@"
        ;;
        *)
        HOST=$(printf "%s\n" "$1"| cut -d : -f 1)
        PORT=$(printf "%s\n" "$1"| cut -d : -f 2)
        shift 1
        ;;
    esac
done

if [ "$HOST" = "" -o "$PORT" = "" ]; then
    echo "Error: you need to provide a host and port to test." >&2
    usage 1
fi

wait_for "$@"

