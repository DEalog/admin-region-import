#!/usr/bin/env bash

if [ -z "${1}" ]; then
  echo "At least one ARS argument is mandatory."
  exit 1
fi

function build_query {
  local type=${1}
  local parent_ars=${2}
  local ars=${3}
  local query=$(cat << EOF
    SELECT
      ars,
      '${parent_ars}' as parent_ars,
      '${type}' as type,
      gen,
      bez
    FROM
      vg250_${type}
    WHERE
      ars LIKE '${ars}%'
EOF
  )
  echo ${query}
}

function build_static_query {
  local query=$(cat << EOF
    SELECT
      ars,
      null as parent_ars,
      'sta' as type,
      gen,
      bez
    FROM
      vg250_sta
    WHERE
      ars = '${1}'
    AND gf = '4'
EOF
  )
  echo ${query}
}

function export_to_csv {
  local ars=${1}
  local query=${2}
  echo "Starting export for ${ars}"
  psql\
    -h localhost\
    -d postgis\
    -U docker\
    -c "Copy ($query) To '/app/data/${ars}.csv' With CSV DELIMITER ',' HEADER;"
  echo "Exported to data/${ars}.csv"
}

echo "localhost:5432:postgis:docker:docker" > ~/.pgpass
chmod 600 ~/.pgpass

state_ars="000000000000"
export_to_csv "0" "$(build_static_query "${state_ars}")"

for ars in "$@"
do
  export_to_csv ${state_ars} "$(build_query "lan" ${state_ars} ${ars:0:2})"
  export_to_csv ${ars:0:2} "$(build_query "rbz" ${ars:0:2} ${ars:0:3})"
  export_to_csv ${ars:0:3} "$(build_query "krs" ${ars:0:3} ${ars:0:3})"
  export_to_csv ${ars} "$(build_query "gem" ${ars} ${ars})"
done

cat << EOF
*******************************************************************************
*                                                                             *
* Successfully exported the data.                                             *
*                                                                             *
*******************************************************************************
EOF
