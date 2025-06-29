# === Base Image with Python and Required Packages ===
FROM python:3.12.9-bullseye AS spark-base

# Install system dependencies and Java 11
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        curl \
        vim \
        unzip \
        rsync \
        openjdk-11-jdk \
        build-essential \
        software-properties-common \
        ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV SPARK_VERSION=3.5.5
ENV SPARK_HOME=/opt/spark
ENV HADOOP_HOME=/opt/hadoop
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
ENV PYSPARK_PYTHON=python3
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"

# Prepare Spark and Hadoop directories
RUN mkdir -p $HADOOP_HOME $SPARK_HOME
WORKDIR $SPARK_HOME

# Download and extract Spark
RUN curl -L https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark.tgz && \
    tar -xvzf spark.tgz --strip-components 1 && \
    rm -f spark.tgz

# Set executable permissions
RUN chmod u+x $SPARK_HOME/sbin/* $SPARK_HOME/bin/*

# Add Spark default configuration
COPY spark-conf/spark-defaults.conf $SPARK_HOME/conf/

# === Layer for Installing Python Dependencies ===
FROM spark-base AS pyspark

COPY requirements.txt .
RUN pip install -r requirements.txt

# === Final Runtime Layer with Extra JARs and Entrypoint ===
FROM pyspark AS pyspark-runner

# Download necessary JARs for AWS and Iceberg support
RUN curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.782/aws-java-sdk-bundle-1.12.782.jar \
        -o /opt/spark/jars/aws-java-sdk-bundle-1.12.782.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar \
        -o /opt/spark/jars/hadoop-aws-3.3.4.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.8.1/iceberg-spark-runtime-3.5_2.12-1.8.1.jar \
        -o /opt/spark/jars/iceberg-spark-runtime-3.5_2.12-1.8.1.jar && \
    curl -L https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.31.45/bundle-2.31.45.jar \
        -o /opt/spark/jars/bundle-2.31.45.jar && \
    curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-lakeformation/1.12.782/aws-java-sdk-lakeformation-1.12.782.jar \
        -o /opt/spark/jars/aws-java-sdk-lakeformation-1.12.782.jar

# Add entrypoint script
COPY entrypoint.sh /opt/spark/
RUN chmod u+x /opt/spark/entrypoint.sh

ENTRYPOINT ["/opt/spark/entrypoint.sh"]
CMD ["bash"]
