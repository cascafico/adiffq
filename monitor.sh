#!/bin/bash

if [ $# -eq 0 ]
   then
     echo "first argument how many days ago monitor changes"
     echo "second argument area name (double quoted if multistring)"
     echo "...exiting"
     exit
fi

if [ -z "$2" ]
  then
    echo "No area supplied"
    exit
fi    
PLACE=$2
PLACE=${PLACE// /%20}


RUN=`date`
T0=`date -d "yesterday 00:00" '+%Y-%m-%d'`T00:00:00Z
T1=`date +"%Y-%m-%d"`T00:00:00Z

if [[ "$1" =~ ^[0-9]+$ ]] ; then 
   T0=`date -d "$1 days ago 00:00" '+%Y-%m-%d'`T00:00:00Z
   else echo "first argument must be an integer"
   exit
fi

AREACODE=`curl -s "http://overpass-api.de/api/interpreter?data=area%5B%22boundary%22%3D%22administrative%22%5D%5B%22name%22%3D%22$PLACE%22%5D%3Bout%20ids%3B%0A" | grep 3600 | awk -F "\"" '{print $2}'`
echo $PLACE
echo $AREACODE
if [ -z $AREACODE  ]
   then
     echo "area name not found (please case sensitive)"
     echo "...exiting"
     exit
fi

# here you can select relation tags
QUERY="http://overpass-api.de/api/interpreter?data=[out:xml][timeout:45][adiff:\"$T0\",\"$T1\"];area($AREACODE)->.searchArea;relation[\"operator\"~\"Club Alpino Italiano|CAI\"](area.searchArea);(._;>;);out meta geom;"


echo "extracting CAIFVG yesterday differences ..."

wget -O adiff$OGGI.xml "$QUERY"

cat adiff$OGGI.xml | grep changeset | awk -F "changeset=" ' { print $2 }'| awk -F "\"" ' { print $2 }' > changeset.lst

echo "sorting and compacting changeset list"
sort -u changeset.lst -o changeset.lst
CHAN=`cat changeset.lst | wc -l`

echo "<h3>Changeset(s) created in interval</h3><br> Query: operator=CAI or operator=Club Alpino Italiano <br> Area: $PLACE<br>Interval: since $1 days ago<p>" > index.html
echo "<style>table, th, td { border: 1px solid black; border-collapse: collapse; }</style>" >> index.html
echo "<table><tr><th>OSMcha</th><th>Achavi</th></tr>" >> index.html

while read -r line
do
    name="$line"
    echo "<tr><td><a href=\"https://osmcha.mapbox.com/changesets/$name?filters=%7B%22ids%22%3A%5B%7B%22label%22%3A%22$name%22%2C%22value%22%3A%22$name%22%7D%5D%7D\"> $line </a></td><td><a href=\"https://overpass-api.de/achavi/?changeset=$name\"> $line </a></td></tr>" >> index.html
done < "changeset.lst"

if [ $CHAN == 0 ]
then 
   echo "<tr><td colspan = \"2\">No changeset between $T0 and $T1</td></tr>" >> index.html
else
   echo "<tr><td colspan = \"2\">$CHAN changeset(s)  between $T0 and $T1</td></tr>" >> index.html
fi

echo "</table><p>This page has been generated on $RUN" >> index.html

