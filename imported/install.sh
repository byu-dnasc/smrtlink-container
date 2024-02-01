# installer variable must be set
[ -z "$INSTALLER" ] && echo "$0: INSTALLER not set" && exit 1
[ ! -f "$INSTALLER" ] && echo "$0: Installer ($INSTALLER) not found." && exit 1
[ -z "$SMRT_ROOT" ] && echo "$0: SMRT_ROOT not set" && exit 1

# extract SMRT Link bundles and modify installprompter script
if [ ! -d $SMRT_ROOT ]; then
    read -p "$0: Extract SMRT Link to $SMRT_ROOT? [y/N] "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        [ -z "$EXTRACT_CMD" ] && echo "$0: EXTRACT_CMD not set" && exit 1
        [ ! -w ${SMRT_ROOT%smrtlink} ] && echo "$0: ${SMRT_ROOT%smrtlink} is not writable." && exit 1
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
    else
        exit 1
    fi
else
    echo "$0: $SMRT_ROOT already exists."
fi

read -p "$0: Install SMRT Link to $SMRT_ROOT? [y/N] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    [ -z "$INSTALL_CMD" ] && echo "$0: INSTALL_CMD not set" && exit 1
    eval "$INSTALL_CMD"
fi