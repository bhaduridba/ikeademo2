#!/usr/bin/env bash
## use pip to install required libraries
## ************************************************* ##
## enable Cloud Build API before running the process ##
## ************************************************* ##

# Setup environment
gcloud config set account 'bhaduridba@gmail.com'
#gcloud config set project ikeademo2

gcloud components update
export PROJECT_ID=$(gcloud config get-value project)
gcloud config set project $PROJECT_ID

export SOURCE_SYSTEM='iSOM'
export APP_NAME='cleveron'
export REGION=us-central1

#export FILES_SOURCE=${SOURCE_SYSTEM}-${PROJECT_ID}-files-source-$(date +%s)
export BUCKET_NAME=${SOURCE_SYSTEM}-${APP_NAME}-files-source

echo $BUCKET_NAME
TOPIC_ID=${SOURCE_SYSTEM}-${APP_NAME}
echo $TOPIC_ID

REGION=us-central1
AE_REGION=us-central

# Create a Cloud Storage bucket owned by DSM  project
gsutil mb gs://$BUCKET_NAME

#Create a Pub/Sub topic in project 1
gcloud pubsub topics create $TOPIC_ID

#Create an App Engine app for the project:
gcloud app create --region=$AE_REGION

#Create a Cloud Scheduler job in this project. The job publishes a message to a Pub/Sub topic at one-minute intervals.
export LOCATION=$REGION
export SCHEDULE="* * * * *"
export MESSAGE_BODY_FROM_FILE=/Users/sobhan/Documents/projects/ikeademo2/test_files/data.json

gcloud scheduler jobs create pubsub publisher-job --location=$LOCATION --schedule=$SCHEDULE  \
  				      --topic=$TOPIC_ID  \
				     --message-body-from-file=$MESSAGE_BODY_FROM_FILE

gcloud scheduler jobs run publisher-job



