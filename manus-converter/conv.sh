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
	cp -v "$SCRIPT_DIR/index.html" "$WORK"
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
	process $(ls *ENG*) en
	process $(ls *NOR*) no
	destination $FOLDER
	mkdir -vp "$OUTPUT/$DST"
	mv -v "$WORK/"*".html" "$OUTPUT/$DST"
	popd
done;

for KEY in $OUTPUT/*; do
	echo "https://web.brunstad.tv/manus/"$(basename $KEY)
done

