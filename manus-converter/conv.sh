#! /bin/bash
IFS=$'\n';

if [[ -z "$1" ]]; then
	echo "Usage: ./conv <PATH TO MANUS FOLDER>"
	echo "For details read the readme or the source"
	exit 3
fi



SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd -P)

WORK="$SCRIPT_DIR/work"
OUTPUT="$SCRIPT_DIR/out"

if [[ ! -d $WORK ]]; then
	mkdir -p $WORK
fi

if [[ ! -d $OUTPUT ]]; then
	mkdir -p $OUTPUT
fi

process () {
	pandoc $1 -o "$WORK/$2.temp.html"
	cat "$SCRIPT_DIR/head.html" "$WORK/$2.temp.html" > "$WORK/$2.html"
	echo '<img src="https://rs.bcc.media/pixel/v1/page?writeKey=2KXgBHx2TYFMi8VPWa4bcWbbBt2&anonymousId=anon&name=manus-'$1'" />' >> "$WORK/$2.html"
	cat "$SCRIPT_DIR/tail.html" >> "$WORK/$2.html"
	rm -v "$WORK/$2.temp.html"
}

destination() {
	DST=$(cat "$SCRIPT_DIR/locations.csv" | grep "$1")
	if [[ ! -z $DST ]]; then
		DST=$(echo $DST| cut -d, -f2)
		return;
	fi

	DST=$(echo "$1" | tr " " _)$(uuidgen)
	echo "$1,$DST" >> "$SCRIPT_DIR/locations.csv"
}

cd "$1"
for FOLDER in $(find . -not -name ".*" -maxdepth 1 -type d); do
	if [[ -z "$FOLDER" ]]; then
		continue
	fi

	pushd  "$1/$FOLDER"
	FOLDER=$(basename $FOLDER)


	cat "$SCRIPT_DIR/index.head.html" > "$WORK/index.html"

	if compgen -G "*ENG*" > /dev/null; then
		process $(ls *ENG*) en
		echo "<ul><a href="en.html">English</a></ul>" >> $WORK/index.html
	fi

	if compgen -G "*NOR*" > /dev/null; then
		process $(ls *NOR*) no
		echo "<ul><a href="no.html">Norsk</a></ul>" >> $WORK/index.html
	fi

	if compgen -G "*DEU*" > /dev/null; then
		process $(ls *DEU*) de
		echo "<ul><a href="de.html">Deutsch</a></ul>" >> $WORK/index.html
	fi

	if compgen -G "*FRA*" > /dev/null; then
		process $(ls *FRA*) fr
		echo "<ul><a href="fr.html">Français</a></ul>" >> $WORK/index.html
	fi

	if compgen -G "*HUN*" > /dev/null; then
		process $(ls *HUN*) hu
		echo "<ul><a href="hu.html">Magyar</a></ul>" >> $WORK/index.html
	fi

	if compgen -G "*POL*" > /dev/null; then
		process $(ls *POL*) pl
		echo "<ul><a href="pl.html">Polski</a></ul>" >> $WORK/index.html
	fi



	echo '<img src="https://rs.bcc.media/pixel/v1/page?writeKey=2KXgBHx2TYFMi8VPWa4bcWbbBt2&anonymousId=anon&name=index-'$FOLDER'" />' >> "$WORK/index.html"
	cat "$SCRIPT_DIR/index.tail.html" >> "$WORK/index.html"


	destination $FOLDER
	mkdir -vp "$OUTPUT/$DST"
	mv -v "$WORK/"*".html" "$OUTPUT/$DST"
	popd
done;

for KEY in $OUTPUT/*; do
	echo "https://web.brunstad.tv/manus/"$(basename $KEY)
done

