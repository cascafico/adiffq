# monitor:sh 
Note: outdated by monitor_tg.sh
- generates an Openstreetmap changeset list involving daily changes based on overpass-turbo query
- builds html page with changeset list
- sends alert to telegram channel

# monitor_tg.sh
- generates an Openstreetmap changeset list involving daily changes based on overpass-turbo query
- builds list of achavi links to involved changesets
- sends ilst to telegram channel
- customizable query, region and channel

## customization
### general
Lines 17-25: set herein 
- REGIONE, mnemonic abbreviation for your region
- CANALE, telegram channel to tend messages
- AREACODE, area indexed by overpass (3600000000 + OSM relation id)
- TELEGRAMCLIPATH, where telegram-bin executable is located
- WORKINGPATH, where you want to store temporary files
### query
Line 43
In this template query will extract the changesets where operator="CAI" OR operator="Club Alpino Italiano" were changed yesterday from 00:00 to 24:00
