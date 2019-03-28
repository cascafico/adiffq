# monitor:sh 
Note: outdated by monitor_tg.sh
- generates an Openstreetmap changeset list involving daily changes based on overpass-turbo query
- builds html page with changeset list
- sends alert to telegram channel

# monitor_tg.sh
The script aims to monitor daily changes in an Openstreetmap area and report them at the end of the day via telegran channel, hence it shuold be run after midnight. To set running time, refer to crontab. You can choose area by areacode id and customize which OSM elements are to be queried.

- generates an Openstreetmap changeset list involving daily changes based on overpass-turbo query
- builds list of achavi links to involved changesets
- sends ilst to telegram channel
- customizable query, region and channel

## customization
### general
Lines 17-25: here you can set
- REGIONE, mnemonic abbreviation for your region
- CANALE, telegram channel to send messages
- AREACODE, area indexed by overpass (3600000000 + OSM relation id)
- TELEGRAMCLIPATH, path of telegram-bin executable 
- WORKINGPATH, where to store temporary files
### query
Line 43
The example query will extract changesets where relations with operator="CAI" or operator="Club Alpino Italiano" (and all its members) were changed yesterday from 00:00 to 24:00

## crontab 
to run periodically 5' after midnight, at prompt run "crontab -e" and add the following line:
5 0 * * * /your-path-to-script/monitor_tg.sh.sh >/dev/null 2>&1 
