#!/bin/sh

OPT=`getopt -n $0 -o i:o: --long id:,outdir: -- "$@"`
eval set -- "$OPT"

while true;
do
case $1 in
    -i|--id)
        opt_id=$2
        ;;
    -o|--outdir)
        opt_outdir=$2
        ;;
    --)
        break
        ;;
esac
shift
done

if [ "" != "$opt_id" ]; then
    perl ./YouTube.pl --id $opt_id
fi

for i in -*
do
    if [ "$i" != "-*" ]; then
        t=`echo $i | sed -e "s/^\-/@/"`
        mv ./$i ./$t
    fi
done

for i in *.flv
do
    if [ "$i" != "*.flv" ]; then
        t=`echo $i | sed -e "s/\.flv/\.mp4/"`
        ffmpeg -i $i -vcodec copy -acodec copy $t > /dev/null 2> /dev/null

        unlink $i
    fi
done

if [ "" != "$opt_outdir" ]; then
    for i in *.mp4
    do
        if [ "$i" = "*.mp4" ]; then
            exit;
        fi
        mv $i $opt_outdir/
    done
fi
