# Spark Standalone on Docker Compose

This project sets up an Apache Spark 3.5.5 standalone cluster using Docker Compose with support for Apache Iceberg and AWS S3.
It includes Spark master, multiple workers, and a history server, pre-configured with Iceberg support and S3 integration.

---

## Features

* Spark 3.5.5 with Hadoop 3 and Java 11
* Iceberg support via SparkSession extensions
* Access to Iceberg tables stored in AWS S3
* Event log and history server enabled

---

## Directory Structure

```
.
├── Dockerfile                # Multi-stage build for Spark with Iceberg + S3
├── docker-compose.yml        # Defines all Spark cluster services
├── entrypoint.sh             # Entrypoint script for Spark roles
├── requirements.txt          # Python dependencies (optional for PySpark jobs)
├── spark-conf/
│   └── spark-defaults.conf   # Spark and Iceberg configuration
```

---

## Quick Start

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd <repo-name>
```

### 2. Build and start Spark cluster

```bash
docker-compose up --build -d
```

This will start the following services:

* Spark Master ([http://localhost:8080](http://localhost:8080))
* Spark Workers ([http://localhost:8088](http://localhost:8088), [http://localhost:8089](http://localhost:8089))
* History Server ([http://localhost:18080](http://localhost:18080))

---

## ⚖Configuration Overview

### spark-defaults.conf

Preconfigured with:

* Iceberg support (`spark.sql.extensions`)
* Hadoop-based Iceberg catalog (`s3cat`)
* AWS S3 (via `s3a://`)
* Event logging and Spark history

### Required JARs

Downloaded automatically:

* Iceberg runtime
* Hadoop AWS connector
* AWS SDKs for S3 and Lake Formation

---

## Submit a Job

Example PySpark shell:

```bash
docker exec -it spark-master /opt/spark/bin/pyspark \
  --master spark://spark-master:7077 \
  --conf spark.sql.catalog.s3cat=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.s3cat.type=hadoop \
  --conf spark.sql.catalog.s3cat.warehouse=s3a://dii-dev/iceberg/
```

---

## Notes

* Make sure your AWS credentials are configured (e.g., via environment variables or IAM role if on ECS)
* Region `ap-southeast-7` is used by default
* S3 path style access is enabled (for compatibility with non-AWS endpoints if needed)

---

## Stop the cluster

```bash
docker-compose down
```

---
