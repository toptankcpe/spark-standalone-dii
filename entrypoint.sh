#!/bin/bash

SPARK_WORKLOAD=$1
SPARK_MASTER_URL=${SPARK_MASTER_URL:-spark://spark-master:7077}
SPARK_CONF_FILE="$SPARK_HOME/conf/spark-defaults.conf"

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"
echo "SPARK_MASTER_URL: $SPARK_MASTER_URL"
echo "Using spark-defaults.conf at: $SPARK_CONF_FILE"

if [ "$SPARK_WORKLOAD" == "master" ]; then
  $SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master \
    --host $(hostname) \
    --port 7077 \
    --webui-port 8080
elif [[ $SPARK_WORKLOAD =~ "worker" ]]; then
  $SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker "$SPARK_MASTER_URL"
elif [ "$SPARK_WORKLOAD" == "history" ]; then
  $SPARK_HOME/bin/spark-class org.apache.spark.deploy.history.HistoryServer
fi


