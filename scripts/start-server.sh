#!/bin/sh
/srv/stackql/stackql --version
echo "starting stackql server..."
nohup /srv/stackql/stackql --execution.concurrency.limit=-1 --dataflow.components.max=50 --dataflow.dependency.max=50 --http.response.pageLimit=-1 --pgsrv.port=5466 srv &
echo "stackql server started"