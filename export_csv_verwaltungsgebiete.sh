#!/usr/bin/env bash

if [ -z "${1}" ]; then
  echo "At least one AGS argument is mandatory."
  exit 1
fi

function build_query {
  local type=${1}
  local parent_ags=${2}
  local ags=${3}
  local query=$(cat << EOF
    SELECT
      ags,
      '${parent_ags}' as parent_ags,
      '${type}' as type,
      gen,
      bez,
      geom
    FROM
      vg250_${type}
    WHERE
      ags LIKE '${ags}%'
EOF
  )
  echo ${query}
}

function build_static_query {
  local query=$(cat << EOF
    SELECT
      ags,
      null as parent_ags,
      'sta' as type,
      gen,
      bez,
      geom
    FROM
      vg250_sta
    WHERE
      ags = '${1}'
    AND gf = '4'
EOF
  )
  echo ${query}
}

function export_to_csv {
  local ags=${1}
  local query=${2}
  echo "Starting export for ${ags}"
  psql\
    -h localhost\
    -d postgis\
    -U docker\
    -c "Copy ($query) To '/app/data/${ags}.csv' With CSV DELIMITER ',' HEADER;"
  echo "Exported to data/${ags}.csv"
}

echo "localhost:5432:postgis:docker:docker" > ~/.pgpass
chmod 600 ~/.pgpass

state_ags="00000000"
export_to_csv "0" "$(build_static_query "${state_ags}")"

for ags in "$@"
do
  export_to_csv ${state_ags} "$(build_query "lan" ${state_ags} ${ags:0:2})"
  export_to_csv ${ags:0:2} "$(build_query "rbz" ${ags:0:2} ${ags:0:3})"
  export_to_csv ${ags:0:3} "$(build_query "krs" ${ags:0:3} ${ags:0:3})"
  export_to_csv ${ags} "$(build_query "gem" ${ags} ${ags})"
done

cat << EOF
*******************************************************************************
*                                                                             *
* Successfully exported the data.                                             *
*                                                                             *
*******************************************************************************
EOF
