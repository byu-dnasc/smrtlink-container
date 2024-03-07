[ -z $SL_HOST ] && echo "Please export SL_HOST" && exit 1
[ -z $SL_HOST_USER ] && echo "Please export SL_HOST_USER" && exit 1

rsync -avz $SL_HOST_USER@$SL_HOST:/home/$SL_HOST_USER/smrtlink-container/data/*.pacb .