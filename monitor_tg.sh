# script monitors specific OSM elements modified during last 24h
# query: http://overpass-turbo.eu/s/Fr0

# if changesets!=0, telegram message to $CANALE will be sent with links to achavi

# REQUIRES 
#  telegram-cli installed 
#  telegram channel $CANALE created
#  areacode: refer to areacodes file or customize you area running this query
#  http://overpass-turbo.eu/s/FwF


# optionally, adding the following row to crontab will check daily at 00:05 AM:
# 5 0 * * * <path>/monitor_CAI.sh >> /dev/null 2>&1


######## start customization
REGIONE="FVG"
CANALE=CAI$REGIONE
CANALE=Cascatest
#AREACODE=3600000000 + <see areacodes file>
AREACODE=3600179296
TELEGRAMCLIPATH=/home/pi/apps/tg/bin/
WORKINGPATH=/tmp
######## end customization

# dates for overpass syntax: 
T0=`date -d "yesterday" '+%Y-%m-%dT%H:%M:%SZ'`
T1=`date                '+%Y-%m-%dT%H:%M:%SZ'`
# dates for messages
IERI=`date -d "yesterday" '+%Y-%m-%d'`
OGGI=`date +"%Y-%m-%d"`

MESSAGGIO="Ci sono modifiche alla rete sentieri $REGIONE tra $T0 e $T1"
NOMODS="Non ci sono modifiche alla rete sentieri $REGIONE tra $T0 e $T1"
REGIONEQ=$REGIONE'adiff'$OGGI'.xml'
RUN=`date`

cd $WORKINGPATH
rm $REGIONE*

echo "extracting overpass adiff differences ..."
curl -G 'http://overpass-api.de/api/interpreter' --data-urlencode 'data=[out:xml][timeout:300][adiff:"'$T0'","'$T1'"];area('$AREACODE')->.searchArea;(relation["operator"="Club Alpino Italiano"](area.searchArea);relation["operator"="CAI"](area.searchArea););(._;>;);out meta geom;' > $REGIONEQ

echo "parsing involved changeset(s)"
cat $REGIONEQ | grep "$IERI\|$OGGI" | grep changeset | awk ' { print substr($0,index($0, "changeset")+11,8) }' > $REGIONEchangeset.lst

echo "sorting and compacting changeset list"
sort -u $REGIONEchangeset.lst -o $REGIONEchangeset.lst

echo "changesets involved:"
CHAN=`cat $REGIONEchangeset.lst | wc -l`
echo $CHAN



if [ $CHAN == 0 ]
then 
   echo "non ci sono modifiche tra $IERI e $OGGI"
   (sleep 6; echo "msg $CANALE $NOMODS"; echo "safe_quit") | $TELEGRAMCLIPATH/telegram-cli -W
   else
   echo "writing talegram message header"
   echo "Ci sono modifiche alla rete sentieri $REGIONE tra $T0 e $T1" >  $REGIONEtelegram_msg.txt
   echo "building changeset list in telegram message"
   while read -r line
   do
       name="$line"
       echo "https://overpass-api.de/achavi/?changeset=$name" >> $REGIONEtelegram_msg.txt
   done < "$REGIONEchangeset.lst"
   (sleep 6; echo "send_text $CANALE $REGIONEtelegram_msg.txt"; echo "safe_quit") | $TELEGRAMCLIPATH/telegram-cli -W
fi

