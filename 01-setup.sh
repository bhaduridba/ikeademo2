#!/usr/bin/env bash
## use pip to install required libraries
## ************************************************* ##
## enable Cloud Build API before running the process ##
## ************************************************* ##

gcloud components update
# Setup environment

export REGION=us-central1
echo $REGION
# git clone https://github.com/bhaduridba/ikeademo2.git .
# cd ikeademo2

## Create streaming source and destination sinks
## Create the Cloud Storage bucket
export PROJECT_ID2='ikeademo2'
echo $PROJECT_ID2

gcloud config set project $PROJECT_ID2

export SOURCE='cleveron'
#export FILES_SOURCE=${PROJECT_ID2}-${SOURCE}-files-source-$(date +%s)
export FILES_SOURCE=${PROJECT_ID2}-${SOURCE}-files-source

echo $FILES_SOURCE

## ------------- test -------------
gsutil mb -c regional -l ${REGION} gs://${FILES_SOURCE}

## Create the BigQuery table demo2 in dataset ikeademo2
export TABLE_NAME='demo2'

bq mk $PROJECT_ID2
bq mk ${PROJECT_ID2}.${TABLE_NAME} schema.json

## Set up the streaming Cloud Function
## To deploy the function:

## Create a Cloud Storage bucket to stage your functions during deployment
## where CLEVRON_FUNCTIONS_BUCKET is set up as an environment variable with a unique name.

#export CLEVERON_FUNCTIONS_BUCKET=${PROJECT_ID}-${SOURCE}-functions-$(date +%s)
echo $CLEVERON_FUNCTIONS_BUCKET
#gsutil mb -c regional -l ${REGION} gs://${CLEVERON_FUNCTIONS_BUCKET}

## Deploy streaming Cloud function
#gcloud functions deploy streaming --region=${REGION} \
#    --source=./functions/streaming --runtime=python37 \
#    --stage-bucket=${CLEVERON_FUNCTIONS_BUCKET} \
#    --trigger-bucket=${FILES_SOURCE}

## Create a Pub/Sub topic, called streaming_error_topic, to handle the error files

#export STREAMING_ERROR_TOPIC=${PROJECT_ID}-${SOURCE}-streaming_error_topic
#echo $STREAMING_ERROR_TOPIC

#gcloud pubsub topics create ${STREAMING_ERROR_TOPIC}

## Create a Pub/Sub topic, called streaming_success_topic, to handle the valid files
#export STREAMING_SUCCESS_TOPIC=${PROJECT_ID}-${SOURCE}-streaming_success_topic
echo $STREAMING_SUCCESS_TOPIC

#gcloud pubsub topics create ${STREAMING_SUCCESS_TOPIC}

# Setup Firestore database
## *************************************** ##
## We can use a Terraform script to provision Firestore separate from this flow ##
## *************************************** ##

# Handle streaming error files

export FILES_ERROR=${PROJECT_ID2}-${SOURCE}-files-error-$(date +%s)
echo $FILES_ERROR
#gsutil mb -c regional -l ${REGION} gs://${FILES_ERROR}

## Deploy streaming_error function to handle error files
#gcloud functions deploy clevron_streaming_error --region=${REGION} \
#    --source=./functions/move_file \
#    --entry-point=move_file --runtime=python37 \
#    --stage-bucket=${CLEVERON_FUNCTIONS_BUCKET} \
#    --trigger-topic=${STREAMING_ERROR_TOPIC} \
#    --set-env-vars SOURCE_BUCKET=${FILES_SOURCE},DESTINATION_BUCKET=${FILES_ERROR}

## Handle successful streaming
## Create  Coldline Cloud Storage bucket. FILES_SUCCESS

export FILES_SUCCESS=${PROJECT_ID2}-${SOURCE}-files-success-$(date +%s)
echo $FILES_SUCCESS
#gsutil mb -c coldline -l ${REGION} gs://${FILES_SUCCESS}

## Deploy streaming_success function to handle valid events
#gcloud functions deploy cleveron_streaming_success --region=${REGION} \
#    --source=./functions/move_file \
#    --entry-point=move_file --runtime=python37 \
#    --stage-bucket=${CLEVERON_FUNCTIONS_BUCKET} \
#    --trigger-topic=${STREAMING_SUCCESS_TOPIC} \
#    --set-env-vars SOURCE_BUCKET=${FILES_SOURCE},DESTINATION_BUCKET=${FILES_SUCCESS}
