#!/usr/bin/env bash
#export KAFKA=/home/ec2-user/kafka/kafka_2.12
#export PATH=$PATH:$KAFKA/bin:/usr/local/bin

# Setup environment
gcloud config set project ikeademo2

export REGION=us-central1

git clone https://github.com/bhaduridba/ikeademo2.git .
cd ikeademo2

# Create streaming source and destination sinks
## Create the Cloud Storage bucket
export FILES_SOURCE=${DEVSHELL_PROJECT_ID}-files-source-$(date +%s)
gsutil mb -c regional -l ${REGION} gs://${FILES_SOURCE}

## Create the BigQuery table demo2 in dataset ikeademo2
bq mk ikeademo2
bq mk ikeademo2.demo2 schema.json

# Set up the streaming Cloud Function
## To deploy the function:

## Create a Cloud Storage bucket to stage your functions during deployment
## where CLEVRON_FUNCTIONS_BUCKET is set up as an environment variable with a unique name.

export CLEVRON_FUNCTIONS_BUCKET=${DEVSHELL_PROJECT_ID}-clevron-functions-$(date +%s)

gsutil mb -c regional -l ${REGION} gs://${CLEVRON_FUNCTIONS_BUCKET}

## Deploy streaming Cloud function
gcloud functions deploy streaming --region=${REGION} \
    --source=./functions/streaming --runtime=python37 \
    --stage-bucket=${CLEVRON_FUNCTIONS_BUCKET} \
    --trigger-bucket=${FILES_SOURCE}

## Create a Pub/Sub topic, called streaming_error_topic, to handle the error files

export STREAMING_ERROR_TOPIC=clevron_streaming_error_topic
gcloud pubsub topics create ${STREAMING_ERROR_TOPIC}

## Create a Pub/Sub topic, called streaming_success_topic, to handle the valid files
export STREAMING_SUCCESS_TOPIC=clevron_streaming_success_topic

# Setup your Firestore database
#Set up your Firestore database
## *************************************** ##
## We can use a Terraform script to provision Firestore separate from this flow ##
## *************************************** ##

# Handle streaming error files
export FILES_ERROR=${DEVSHELL_PROJECT_ID}-clevron-files-error-$(date +%s)
gsutil mb -c regional -l ${REGION} gs://${FILES_ERROR}

## Deploy streaming_error function to handle error files
gcloud functions deploy clevron_streaming_error --region=${REGION} \
    --source=./functions/move_file \
    --entry-point=move_file --runtime=python37 \
    --stage-bucket=${CLEVRON_FUNCTIONS_BUCKET} \
    --trigger-topic=${STREAMING_ERROR_TOPIC} \
    --set-env-vars SOURCE_BUCKET=${FILES_SOURCE},DESTINATION_BUCKET=${FILES_ERROR}

# Handle successful streaming
## Create  Coldline Cloud Storage bucket. FILES_SUCCESS
export FILES_SUCCESS=${DEVSHELL_PROJECT_ID}-clevron-files-success-$(date +%s)
gsutil mb -c coldline -l ${REGION} gs://${FILES_SUCCESS}

## Deploy streaming_success function to handle valid events
gcloud functions deploy clevron_streaming_success --region=${REGION} \
    --source=./functions/move_file \
    --entry-point=move_file --runtime=python37 \
    --stage-bucket=${CLEVRON_FUNCTIONS_BUCKET} \
    --trigger-topic=${STREAMING_SUCCESS_TOPIC} \
    --set-env-vars SOURCE_BUCKET=${FILES_SOURCE},DESTINATION_BUCKET=${FILES_SUCCESS}
