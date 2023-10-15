#!/bin/sh
/srv/stackql/stackql --version
echo "starting stackql server..."
nohup /srv/stackql/stackql --http.response.pageLimit=-1 --pgsrv.port=5466 srv &
echo "stackql server started"
start-notebook.sh --NotebookApp.token=''