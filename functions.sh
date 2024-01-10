CONTAINER=smrtlink
ENV_FILE=imported.env
container_output_file="$HOME/.singularity/instances/logs/$HOSTNAME/$USER/${CONTAINER}.out"

command -v singularity &> /dev/null || echo 'Warning: singularity command not found.'

build() {
    singularity build \
        --fakeroot \
        --force \
        --build-arg user="$USER" \
        smrt.sif smrt.def
}

container() { singularity instance list | grep -q $CONTAINER; }

shell() {
    ! container && echo "The container is not running." && return 1
    singularity shell \
        --env-file $ENV_FILE \
        instance://$CONTAINER
}

smrtservices() { curl -s -k http://localhost:9091/status | grep -q "smrtlink"; }

sanity() {
    ! container && echo "The container is not running." && return 1
    ! smrtservices && echo "Container is running, but could not get SMRT Link status." && return 1
}

start() {
    container && echo "The container is already running." && return 1
    singularity instance start smrt.sif $CONTAINER
}

stop() {
    ! container && echo "The container is not running." && return 1
    singularity instance stop $CONTAINER
    read -p "Clear container log? [y/N] " -n 1 -r
    [[ $REPLY =~ ^[Yy]$ ]] && rm -f $container_output_file && echo ""
}

log() {
    ! container && echo "The container is not running." && return 1
    cat "$container_output_file"
}