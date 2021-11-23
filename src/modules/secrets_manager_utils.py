import os
import json
import boto3


def get_secretsmanager_client():
    return boto3.client("secretsmanager")


def get_secret(secret_name, env):
    if env == "dev":
        print("[INFO] Retrieving credentials from environment")
        return {
            "username": os.environ.get("MYSQL_USER"),
            "password": os.environ.get("MYSQL_PASS"),
            "host": os.environ.get("MYSQL_HOST"),
            "port": int(os.environ.get("MYSQL_PORT")),
        }

    client = get_secretsmanager_client(env)
    print("[INFO] Retrieving credentials from secrets manager")
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        if "SecretString" in get_secret_value_response:
            secret = json.loads(get_secret_value_response["SecretString"])
            return {
                "username": secret["username"],
                "password": secret["password"],
                "host": secret["host"],
                "port": secret["port"],
            }
    except Exception as e:
        print(e)
