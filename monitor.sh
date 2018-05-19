#!/bin/bash

OGGI=`date +"%Y-%m-%d"`
IERI=`date -d "yesterday 13:00" '+%Y-%m-%d'`

echo "extracting CAIFVG differences from yesterday..."

# TBD: insert control if changefile exists and has nodes and loop until got a valid one

wget -O adiff$OGGI.xml "http://overpass-api.de/api/interpreter?data=%5Bout%3Axml%5D%5Btimeout%3A45%5D%5Badiff%3A%22${IERI}T00%3A00%3A00Z%22%2C%22${OGGI}T00%3A00%3A00Z%22%5D%3Barea%283600179296%29%2D%3E%2EsearchArea%3B%28relation%5B%22operator%22%3D%22Club%20Alpino%20Italiano%22%5D%28area%2EsearchArea%29%3Brelation%5B%22operator%22%3D%22CAI%22%5D%28area%2EsearchArea%29%3B%29%3B%28%2E%5F%3B%3E%3B%29%3Bout%20meta%20geom%3B%0A"


echo "changesets involved:"

cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "node id=" | grep visible | awk -F '\"' '{print $10}' | sort -u > changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "way id=" | grep visible | awk -F '\"' '{print $10}' | sort -u >> changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "relation id=" | awk -F '\"' '{print $8}' | sort -u >> changeset.lst

sort -u changeset.lst -o changeset.lst

#https://overpass-api.de/achavi/?changeset=59069589
#https://osmcha.mapbox.com/changesets//59069589

# directly to changeset form:
# https://osmcha.mapbox.com/changesets/59069589?filters=%7B%22ids%22%3A%5B%7B%22label%22%3A%2259073166%22%2C%22value%22%3A%2259073166%22%7D%5D%7D


rm index.html

echo "<style>table, th, td { border: 1px solid black; border-collapse: collapse; }</style>" > index.html
echo "<table><tr><th>OSMcha</th><th>Achavi</th></tr>" >> index.html

while read -r line
do
    name="$line"
    echo "<tr><td><a href=\"https://osmcha.mapbox.com/changesets/$name\"> $line </a></td><td><a href=\"https://overpass-api.de/achavi/?changeset=$name\"> $line </a></td></tr>" >> index.html
done < "changeset.lst"

echo "</table>" >> index.html
