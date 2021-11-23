import os
import sys
import time

from modules.secrets_manager_utils import get_secret
from modules.process import process

args = sys.argv[1:]
if len(args) <= 0 or str(args[0]).strip() == "":
    print("[ERROR] Missing parameter")
    sys.exit(127)

if __name__ in "__main__":
    ENV = os.environ.get("ENV", "dev")
    BUCKET_NAME = os.environ.get("BUCKET_NAME")
    MYSQL_DATABASE = str(args[0]).strip()

    initial_time = time.time()

    secret_name = f"app/mysql/{ENV}"
    secret_dict = get_secret(secret_name, ENV)
    process(secret_dict, MYSQL_DATABASE, BUCKET_NAME, ENV)

    elapsed_time_secs = time.time() - initial_time
    print("[INFO] Dumping tooks %.2f seconds" % (elapsed_time_secs))
