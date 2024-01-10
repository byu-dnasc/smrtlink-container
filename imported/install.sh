# set variables if not already set
[ -z "$SMRT_ROOT" ] && SMRT_ROOT=/opt/pacbio/smrtlink
[ -z "$INSTALLER" ] && INSTALLER=./smrtlink-release_13.0.0.207600_linux_x86-64_libc-2.17_anydistro.run
[ -z "$EXTRACT_CMD" ] && EXTRACT_CMD="$INSTALLER --extract-bundles-only --rootdir $SMRT_ROOT"
[ -z "$INSTALL_CMD" ] && INSTALL_CMD="$INSTALLER --batch --no-extract --lite true --jmstype NONE --nworkers 4 --rootdir $SMRT_ROOT"

# extract SMRT Link bundles and modify installprompter script
if [ ! -d $SMRT_ROOT ]; then
    read -p "Extract SMRT Link to $SMRT_ROOT? [y/N] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "$EXTRACT_CMD"
        # remove -a option from lines 11744,45,49,50 of installprompter
        installprompter="$SMRT_ROOT/install/smrtlink-release_13.0.0.207600/admin/bin/installprompter"
        if [ -f $installprompter ]; then
            for line in 11744 11745 11749 11750; do
                sed -i "${line}s/cp -a/cp/" $installprompter
            done
            # replace -a option with -r on lines 13698 and 13703 of installprompter
            for line in 13698 13703; do
                sed -i "${line}s/cp -a/cp -r/" $installprompter
            done
        fi
        # TODO: delete all unnecessary bundles
    fi
fi

read -p "Install SMRT Link to $SMRT_ROOT? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$INSTALL_CMD"
fi