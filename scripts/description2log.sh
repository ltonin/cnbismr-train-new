#!/bin/bash
# 2010-11-26  Michele Tavella <michele.tavella@epfl.ch>

ROOTFOLDER=$1

if [ "z$ROOTFOLDER" == "z" ]; then
	echo "Error: descrition2log.sh ROOTFOLDER";
	exit 1;
fi

echo "[descrition2log] Root folder is: $ROOTFOLDER";

for txtfile in `find  $ROOTFOLDER -iname "description.txt"`; do
	dirname=`dirname $txtfile`;
	name=`basename $dirname`;
	basename=`echo $name | sed -e s/_/\ /g | awk '{print $2 "_" $1}'`;
	tmpfile="$dirname/$basename.log.tmp"
	logfile="$dirname/$basename.log"

	echo "+- txtfile:  $txtfile"
	echo "|- dirname:  $dirname"
	echo "|- name:     $name"
	echo "|- basename: $basename"
	echo "|- tmpfile:  $tmpfile"
	echo "|- logfile:  $logfile"

	# Using awk to reshuffle, should be enough.
	# I extract up to 9 fields to be on the safe side.
	cat $txtfile | \
		awk '{print $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9}' | \
		tr '[A-Z]' '[a-z]' | \
		sed -e s/analysis/classifier/g | \
		sed 's/  */ /g' > $tmpfile
	
	txtlines=`grep -n txt $tmpfile | cut -f1 -d:`
	if [ "z$txtlines" == "z" ]; then
		cat $tmpfile > $logfile;
		echo "\`- Done, w/o corrections"
	else
		cutlines=''
		for l in $txtlines; do
			let n=$l-1;
			cutlines="$cutlines $n"
		done

		echo "|- txtlines:  `echo $txtlines | xargs`"
		echo "|- cutlines:  `echo $cutlines | xargs`"
		./donotprintlines.pl $tmpfile $cutlines | sed -e s/txt/gdf/g > $logfile
		echo "\`- Done, cutting lines"
	fi
	rm $tmpfile;
done

exit 0;
