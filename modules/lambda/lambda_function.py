import json
import boto3
import os
import urllib.parse
import logging

# Initialize AWS clients
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retrieve environment variables
BUCKET_NAME = os.environ.get('BUCKET_NAME')
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE')

# Initialize DynamoDB table resource
table = dynamodb.Table(DYNAMODB_TABLE)

def lambda_handler(event, context):
    """
    Lambda function to process S3 events and insert data into DynamoDB.
    
    Parameters:
    - event: dict, required
        The event payload.
    - context: object, required
        The runtime information of the Lambda function.
    """
    logger.info("Received event: %s", json.dumps(event))
    
    for record in event.get('Records', []):
        # Extract bucket name and object key from the event
        s3_info = record.get('s3', {})
        bucket = s3_info.get('bucket', {}).get('name')
        key = s3_info.get('object', {}).get('key')
        
        if not bucket or not key:
            logger.error("Missing bucket name or object key in the event record.")
            continue
        
        # Decode the S3 object key (handles spaces and special characters)
        decoded_key = urllib.parse.unquote_plus(key)
        logger.info("Processing object: %s from bucket: %s", decoded_key, bucket)
        
        try:
            # Retrieve the object from S3
            response = s3_client.get_object(Bucket=bucket, Key=decoded_key)
            data = response['Body'].read().decode('utf-8')
            logger.debug("Raw data read from S3: %s", data)
            
            # Parse JSON data
            item = json.loads(data)
            logger.debug("Parsed JSON data: %s", item)
            
            # Validate the required attribute
            if 'id' not in item:
                logger.error("Missing 'id' attribute in the data: %s", item)
                continue
            
            # Insert item into DynamoDB
            table.put_item(Item=item)
            logger.info("Successfully inserted item with ID: %s into DynamoDB", item['id'])
        
        except json.JSONDecodeError as jde:
            logger.error("JSON decoding failed for object %s from bucket %s: %s", decoded_key, bucket, str(jde))
        
        except boto3.exceptions.Boto3Error as boto_err:
            logger.error("Boto3 error occurred: %s", str(boto_err))
            raise boto_err  # Re-raise exception to trigger retry
        
        except Exception as e:
            logger.error("Unexpected error processing object %s from bucket %s: %s", decoded_key, bucket, str(e))
            raise e  # Re-raise exception to trigger retry