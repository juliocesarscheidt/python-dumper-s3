import os
import boto3

from boto3.s3.transfer import TransferConfig
from botocore.client import Config

def get_s3_client(env):
    if env == "dev":
        return boto3.client(
            "s3",
            aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY"),
            region_name=os.environ.get("AWS_DEFAULT_REGION", "sa-east-1"),
            config=Config(signature_version='s3v4'),
            endpoint_url=os.environ.get("S3_ENDPOINT_URL", "http://minio:9000"),
        )
    else:
        return boto3.client("s3")


def upload_file_s3(s3_client, bucket_name, path_key, file_name):
    print(f"[INFO] Uploading file {file_name} to S3...")
    GB = 1024 ** 3
    config = TransferConfig(multipart_threshold=1 * GB)
    s3_client.upload_file(
        file_name, bucket_name, path_key + "/" + file_name, Config=config
    )
