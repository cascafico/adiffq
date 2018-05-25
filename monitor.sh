#!/bin/bash

T0=`date -d "yesterday 00:00" '+%Y-%m-%d'`T00:00:00Z
T1=`date +"%Y-%m-%d"`T00:00:00Z
IERI=`date -d "yesterday 00:00" '+%Y-%m-%d'`
OGGI=`date +"%Y-%m-%d"`
REGIONE="Friuli Venezia Giulia"

RUN=`date`

# query in bbox has more chences to be successful
QUERY="http://overpass-api.de/api/interpreter?data=[out:xml][timeout:120][adiff:\"$T0\",\"$T1\"];(relation[\"operator\"=\"Club Alpino Italiano\"](45.4697,11.7663,47.0158,14.1201);relation[\"operator\"=\"CAI\"](45.4697,11.7663,47.0158,14.1201););(._;>;);out meta geom;"

QUERYGEO="[out:xml][timeout:45][adiff:\"$T0\",\"$T1\"];area(3600179296)->.searchArea;(relation[\"operator\"=\"Club Alpino Italiano\"](area.searchArea);relation[\"operator\"=\"CAI\"](area.searchArea););(._;>;);out meta geom;"

cd /tmp

echo "extracting CAIFVG yesterday differences ..."

wget -O adiff$OGGI.xml "$QUERY"

# TBD: insert control if changefile exists and has nodes and loop until got a valid one

#cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "node id=" | grep visible | awk -F '\"' '{print $10}' | sort -u > changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "node id=" | awk -F '\"' '{print $12}' | sort -u > changeset.lst

# check if more reliable with changeset field separator
#cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "way id=" | grep visible | awk -F '\"' '{print $10}' | sort -u >> changeset.lst
cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "way id=" | awk -F '\"' '{print $8}' | sort -u >> changeset.lst

cat adiff$OGGI.xml | grep "$IERI\|$OGGI" | grep "relation id=" | awk -F '\"' '{print $8}' | sort -u >> changeset.lst

echo "sorting and compacting changeset list"
sort -u changeset.lst -o changeset.lst
CHAN=`cat changeset.lst | wc -l`

rm index.html
echo "Changeset(s) created in the last 24h, involving operator=CAI or operator=Club Alpino Italiano in $REGIONE<p>" > index.html
echo "<style>table, th, td { border: 1px solid black; border-collapse: collapse; }</style>" >> index.html
echo "<table><tr><th>OSMcha</th><th>Achavi</th></tr>" >> index.html

while read -r line
do
    name="$line"
    echo "<tr><td><a href=\"https://osmcha.mapbox.com/changesets/$name?filters=%7B%22ids%22%3A%5B%7B%22label%22%3A%22$name%22%2C%22value%22%3A%22$name%22%7D%5D%7D\"> $line </a></td><td><a href=\"https://overpass-api.de/achavi/?changeset=$name\"> $line </a></td></tr>" >> index.html
done < "changeset.lst"

if [ $CHAN == 0 ]; then 
   echo "<tr><td colspan = \"2\">No changeset between $T0 and $T1</td></tr>" >> index.html
fi

echo "</table><p>This page has been generated on $RUN" >> index.html

mv index.html /var/www/osm/dailyCAI.html
