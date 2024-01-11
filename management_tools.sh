source .env

command -v singularity &> /dev/null || echo 'Warning: singularity command not found.'

build() {
    singularity build \
        --fakeroot \
        --force \
        --build-arg smrt_root=$SMRT_ROOT \
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
}

stop() {
    ! container && echo "The container is not running." && return 1
    singularity instance stop $CONTAINER
}

log() {
    [ ! -f "$CONTAINER_LOG" ] && echo "The container log does not exist." && return 1
    cat "$CONTAINER_LOG"
    [ -s "${CONTAINER_LOG/.out/.err}" ] && \
        echo "################### ERROR LOG ###################" && \
        cat "${CONTAINER_LOG/.out/.err}"
    read -p "Clear container logs? [y/N] " -n 1 -r
    [[ $REPLY =~ ^[Yy]$ ]] && \
        > $CONTAINER_LOG && \
        > ${CONTAINER_LOG/.out/.err} && \
        echo ""
    return 0
}