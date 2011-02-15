#!/bin/sh

debug() {
    word=$1;
    if [ $opt_debug ]; then
        echo $word;
    fi
}

OPT=`getopt -n $0 -o f:i:I:d --long file:,id:,outmp4:,outm4v:,debug -- "$@"`
eval set -- "$OPT"

while true;
do
case $1 in
    -f|--file)
        opt_file=$2
        ;;
    -i|--id)
        opt_id=$2
        ;;
    --outmp4)
        opt_outmp4=$2
        ;;
    --outm4v)
        opt_outm4v=$2
        ;;
    -d|--debug)
        opt_debug=true
        ;;
    --)
        break
        ;;
esac
shift
done

arg='';
if [ "" != "$opt_id" ]; then
    arg="--id=$opt_id";
fi

if [ "" != "$opt_file" ]; then
    arg="$arg --file=$opt_file";
fi

if [ $opt_debug ]; then
    arg="$arg --debug";
fi

if [ "" != "$arg" ]; then
    perl ./YouTube.pl $arg
fi

for i in -*
do
    if [ "$i" != "-*" ]; then
        t=`echo $i | sed -e "s/^\-/@/"`
        mv ./$i ./$t
    fi
done

for i in *.mp4
do
    if [ "$i" != "*.mp4" ]; then
        t=`echo $i | sed -e "s/\.mp4/\.m4v/"`
        ffmpeg -i "$i" -f ipod -vcodec mpeg4 -b 1200k -mbd 2 -flags mv4+aic -trellis 2 -cmp 2 -subcmp 2 -s 320x180 -r 30000/1001 -acodec libfaac -ar 44100 -ab 128k "$t" > /dev/null 2> /dev/null
    fi
done

for i in *.flv
do
    if [ "$i" != "*.flv" ]; then
        t=`echo $i | sed -e "s/\.flv/\.mp4/"`
        ffmpeg -i "$i" -vcodec copy -acodec copy "$t" > /dev/null 2> /dev/null
        t=`echo $i | sed -e "s/\.flv/\.m4v/"`
        ffmpeg -i "$i" -f ipod -vcodec mpeg4 -b 1200k -mbd 2 -flags mv4+aic -trellis 2 -cmp 2 -subcmp 2 -s 320x180 -r 30000/1001 -acodec libfaac -ar 44100 -ab 128k "$t" > /dev/null 2> /dev/null

        unlink $i
    fi
done

if [ "" != "$opt_outmp4" ]; then
    for i in *.mp4
    do
        if [ "$i" != "*.mp4" ]; then
            mv $i "$opt_outmp4/"
        fi
    done
fi

if [ "" != "$opt_outm4v" ]; then
    for i in *.m4v
    do
        if [ "$i" != "*.m4v" ]; then
            mv $i "$opt_outm4v/"
        fi
    done
fi

