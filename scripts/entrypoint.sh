#!/bin/sh
/srv/stackql/stackql --version
echo "starting stackql server..."
nohup /srv/stackql/stackql --auth="${STACKQL_PROVIDER_AUTH}" --pgsrv.port=5444 srv &
echo "stackql server started"
start-notebook.sh --NotebookApp.token=''