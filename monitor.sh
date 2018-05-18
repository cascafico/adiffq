#!/bin/bash

OGGI=`date +"%Y-%m-%d"`
IERI=`date -d "yesterday 13:00" '+%Y-%m-%d'`

echo "extracting CAIFVG differences from yesterday..."

#wget -O adiff$OGGI.xml "http://overpass-api.de/api/interpreter?data=%5Bout%3Axml%5D%5Btimeout%3A45%5D%5Badiff%3A%22${IERI}T00%3A00%3A00Z%22%2C%22${OGGI}T00%3A00%3A00Z%22%5D%3Barea%283600179296%29%2D%3E%2EsearchArea%3B%28relation%5B%22operator%22%3D%22Club%20Alpino%20Italiano%22%5D%28area%2EsearchArea%29%3Brelation%5B%22operator%22%3D%22CAI%22%5D%28area%2EsearchArea%29%3B%29%3B%28%2E%5F%3B%3E%3B%29%3Bout%20meta%20geom%3B%0A"


echo "changesets involved:"

cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "node id=" | grep visible | awk -F '\"' '{print $10}' | sort -u > changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "way id=" | grep visible | awk -F '\"' '{print $10}' | sort -u >> changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "relation id=" | awk -F '\"' '{print $8}' | sort -u >> changeset.lst

sort -u changeset.lst -o changeset.lst

#https://overpass-api.de/achavi/?changeset=59069589
#https://osmcha.mapbox.com/changesets//59069589
#<a href="url">link text</a>

rm index.html

while read -r line
do
    name="$line"
    echo "<a href=\"https://osmcha.mapbox.com/changesets/$name\"> changeset $line </a><br>" >> index.html
done < "changeset.lst"
