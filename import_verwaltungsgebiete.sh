#!/usr/bin/env bash

# Config
ARCHIVE_NAME=vg250_01-01.utm32s.shape.ebenen
DATA_URL="https://daten.gdz.bkg.bund.de/produkte/vg/vg250_ebenen_0101/aktuell/${ARCHIVE_NAME}.zip"
SUB_FOLDER=vg250_ebenen_0101

cd data

if [ ! -f "${ARCHIVE_NAME}.zip" ]; then
  echo "Downloading ${ARCHIVE_NAME}"
  curl\
    -o "${ARCHIVE_NAME}.zip"\
    ${DATA_URL}
else
  echo "Archive found. Skipping download."
fi
unzip -o "${ARCHIVE_NAME}.zip"

cd "${ARCHIVE_NAME}/${SUB_FOLDER}/"

echo "Starting conversion to SQL"
for f in *.shp
do
  shp2pgsql -s 25832 $f public.`basename $f .shp` > `basename $f .shp`.sql
done
echo "Converted shape data to SQL"

echo "localhost:5432:postgis:docker:docker" > ~/.pgpass
chmod 600 ~/.pgpass

echo "Starting import"
for f in *.sql
do
  psql -h localhost -d postgis -U docker -f $f > /dev/null
done
echo "Successfully imported converted data"

cat << EOF
*******************************************************************************
*                                                                             *
* Successfully imported the data.                                             *
*                                                                             *
*******************************************************************************
EOF
