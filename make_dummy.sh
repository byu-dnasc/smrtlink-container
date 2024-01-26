[ -z $1 ] && echo "Usage: $ $(basename $0) <revio_run_subdir_path> [NAME]" && exit 1

[ ! -d $1 ] && echo "Directory $1 does not exist." && exit 1

OUTPUT_DIR=~/datasets
[ ! -d $OUTPUT_DIR ] && echo "Directory $OUTPUT_DIR must exist." && exit 1

# use NAME if exists, otherwise use random
DATASET_DIR=$([ -z $2 ] && mktemp -d $OUTPUT_DIR/XXX || echo $OUTPUT_DIR/$2 )

cd $1
# create directories
find . -mindepth 1 -maxdepth 1 -type d -exec mkdir $DATASET_DIR/{} \;
# copy XMLs, JSONs and ZIPs
find . -type f \
    \( -name *.xml \
    -o -name *.json \
    -o -name *.zip \) \
    -exec cp {} $DATASET_DIR/{} \;
# create dummy BAM and PBI files
SAM_CONTENTS="@HD\tVN:1.6\tSO:unknown\tpb:5.0.0\n@RG\tID:1\tPL:PACBIO\nname\t4\t*\t0\t255\t*\t*\t0\t0\tTATTT\tIIIII\tRG:Z:1"
for BAM_FILE in $(find . -name *.bam); do
    echo -e $SAM_CONTENTS | samtools view -bS - > $DATASET_DIR/$BAM_FILE
    pbindex $DATASET_DIR/$BAM_FILE
done
# create empty files named after everything else (TXT, LOG, etc.)
find . -type f \
    \( -not -name *.xml \
    -o -not -name *.json \
    -o -not -name *.zip \
    -o -not -name *.bam* \) \
    -exec touch $DATASET_DIR/{} \;
echo "Lite version of $1 created in $DATASET_DIR"