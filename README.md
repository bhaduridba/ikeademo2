# Serverless Streaming into BigQuery
## This project will be a PoC to showcase how a Cloud function will automatically fire
## to ingest from incoming event in google storage into BigQuery
## This will be a Production implementation design

## Author: Sobhan Bhaduri
## Date: 14-Mar-2022
## Version: 1

# Streaming data from Cloud Storage into BigQuery using Cloud Functions
This code looks at a complete ingest pipeline all the way from capturing streaming events 
(upload of files to Cloud Storage from a Pub/Sub topic in another project), to doing basic processing, error handling, logging and 
insert stream to bigquery. The example captures events from a bucket (object create) with 
Cloud Function, reads the file and stream the content (JSON) to a table in BigQuery. 
If something goes wrong, the function logs the results in Cloud Logging and Firestore, for post analysis. 
Finally the data from the BigQuery can be visualized using DataStudio or Qlik or a front end Web UI with 
API integration.