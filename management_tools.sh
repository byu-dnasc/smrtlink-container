source .env

command -v singularity &> /dev/null || echo 'Warning: singularity command not found.'

build() {
    singularity build \
        --fakeroot \
        --force \
        --build-arg smrt_root=$SMRT_ROOT \
        --build-arg start_signal="$START_SIGNAL" \
        container.sif container.def
}

install() {
    container && echo "stop the container before doing install." && return 1
    singularity exec \
        --env-file $CONTAINER_ENV \
        container.sif \
        bash /imported/install.sh
}

container() { singularity instance list | grep -q $CONTAINER; }

shell() {
    ! container && echo "The container is not running." && return 1
    singularity shell \
        --env-file $CONTAINER_ENV \
        instance://$CONTAINER
}

smrtservices() { curl -s -k http://localhost:9091/status | grep -q "smrtlink"; }

sanity() {
    ! container && echo "The container is not running." && return 1
    ! smrtservices && echo "Container is running, but could not get SMRT Link status." && return 1
    return 0
}

start() {
    container && echo "The container is already running." && return 1
    singularity instance start container.sif $CONTAINER
    follow
}

stop() {
    ! container && echo "The container is not running." && return 1
    singularity instance stop -F $CONTAINER
}

log() {
    [ ! -f "$CONTAINER_LOG" ] && echo "The container log does not exist." && return 1

    # get line number of last time the start script was initiated
    LINE_OUT=$(grep -n "$START_SIGNAL" $CONTAINER_LOG | tail -n 1 | cut -d: -f1)
    LINE_ERR=$(grep -n "$START_SIGNAL" ${CONTAINER_LOG/.out/.err} | tail -n 1 | cut -d: -f1)

    echo "Line $LINE_OUT to the end of $CONTAINER_LOG:"
    tail -n +$LINE_OUT $CONTAINER_LOG | awk '{print "+ " $0}'
    echo "Line $LINE_ERR to the end of ${CONTAINER_LOG/.out/.err}:"
    tail -n +$LINE_ERR ${CONTAINER_LOG/.out/.err} | awk '{print "- " $0}'
}

follow() {

    [ ! -f "$CONTAINER_LOG" ] && echo "The container log does not exist." && return 1

    # get line number of last time the start script was initiated
    LINE_OUT=$(grep -n "$START_SIGNAL" $CONTAINER_LOG | tail -n 1 | cut -d: -f1)
    LINE_ERR=$(grep -n "$START_SIGNAL" ${CONTAINER_LOG/.out/.err} | tail -n 1 | cut -d: -f1)

    [ -z "$LINE_OUT" ] && [ -z "$LINE_ERR" ] && echo "Startscript activity not detected in log." && return 1
    
    # in the background, follow the logs, starting at the last time the start script was initiated
    TAIL_OUT_PID=$(tail -f -n +$LINE_OUT $CONTAINER_LOG > /tmp/container.out & echo $!)
    TAIL_ERR_PID=$(tail -f -n +$LINE_ERR ${CONTAINER_LOG/.out/.err} > /tmp/container.err & echo $!)

    # follow the logs in the foreground
    echo "Enter 'Ctrl-C' to stop following logs."
    tail -f -n +1 /tmp/container.err /tmp/container.out &
    TAIL_PID=$!

    trap "kill $TAIL_PID" SIGINT

    wait $TAIL_PID
    echo
    kill $TAIL_OUT_PID; kill $TAIL_ERR_PID
    rm -f /tmp/container.out /tmp/container.err
    trap - SIGINT

}