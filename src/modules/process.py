import os
import glob
import time
import subprocess

from datetime import datetime
from multiprocessing import cpu_count, Process

from .database import get_database_engine, get_tables
from .s3_utils import get_s3_client, upload_file_s3
from .file_utils import zip_files, remove_files


DUMP_MODE = os.environ.get("DUMP_MODE", "database")
MAX_TABLES = (
    int(os.environ.get("MAX_TABLES"))
    if os.environ.get("MAX_TABLES") is not None and os.environ.get("MAX_TABLES") != ""
    else None
)
PARALLEL_PROCESSES_NUM = int(os.environ.get("PARALLEL_PROCESSES_NUM", "4"))
CLEAN_FILES = (
    bool(eval(str(os.environ.get("CLEAN_FILES"))))
    if os.environ.get("CLEAN_FILES") is not None and os.environ.get("CLEAN_FILES") != ""
    else True
)


def get_secrets_from_dict(secret_dict):
    username = secret_dict["username"]
    password = secret_dict["password"]
    host = secret_dict["host"]
    port = secret_dict["port"]
    return [username, password, host, port]


def dump_database(secret_dict, current_datetime, database):
    print("[INFO] Process ID", os.getpid())
    [username, password, host, port] = get_secrets_from_dict(secret_dict)

    cmd_args = "--compress --single-transaction --skip-add-locks --skip-lock-tables"
    cmd = f'mysqldump -h"{host}" -P"{port}" -u"{username}" -p"{password}" '
    cmd += f'{cmd_args} "{database}"'
    print("[INFO] cmd", cmd)

    output_file = open(f"{database}-{current_datetime}.sql", "w")
    cmd_return = subprocess.run(
        cmd, shell=True, check=True, stdout=output_file, stderr=subprocess.PIPE
    )
    output_file.close()

    return cmd_return


def dump_table(secret_dict, current_datetime, database, table_name):
    print("[INFO] Process ID", os.getpid())
    [username, password, host, port] = get_secrets_from_dict(secret_dict)

    cmd_args = "--compress --single-transaction --skip-add-locks --skip-lock-tables"
    cmd = f'mysqldump -h"{host}" -P"{port}" -u"{username}" -p"{password}" '
    cmd += f'{cmd_args} "{database}" "{table_name}"'
    print("[INFO] cmd", cmd)

    output_file = open(f"{database}-{table_name}-{current_datetime}.sql", "w")
    cmd_return = subprocess.run(
        cmd, shell=True, check=True, stdout=output_file, stderr=subprocess.PIPE
    )
    output_file.close()

    return cmd_return


def process(secret_dict, database, bucket_name, env):
    engine = get_database_engine(secret_dict)
    print("[INFO] Process ID", os.getpid())
    CURRENT_DATETIME = datetime.utcnow().strftime("%Y-%m-%d-%H-%M-%S")
    print("[INFO] CPU count", cpu_count())
    print("[INFO] Parallel processes", PARALLEL_PROCESSES_NUM)

    if DUMP_MODE == "table":
        processes = []
        rows = get_tables(engine, database, from_cache=bool(env == "dev"))
        for row in rows[0:MAX_TABLES]:
            try:
                TABLE_NAME = row["table_name"]
                print(f"[INFO] Dumping table {TABLE_NAME}...")
                p = Process(
                    target=dump_database,
                    args=(secret_dict, CURRENT_DATETIME, database,),
                )
                p.start()
                processes.append(p)
            except Exception as e:
                print(e)

            if len(processes) >= PARALLEL_PROCESSES_NUM:
                print("[INFO] Awaiting processes...")
                for p in processes:
                    p.join()
                    if p.is_alive():
                        time.sleep(1)
                processes = []

        if len(processes) >= 0:
            for p in processes:
                p.join()
                if p.is_alive():
                    time.sleep(1)
            processes = []

    elif DUMP_MODE == "database":
        print(f"[INFO] Dumping database {database}...")
        p = Process(
            target=dump_database, args=(secret_dict, CURRENT_DATETIME, database,),
        )
        p.start()
        p.join()

    sql_files = glob.glob(os.path.join(".", "*.sql"))

    if len(sql_files) > 0:
        zip_file_name = f"{database}-{CURRENT_DATETIME}.zip"
        zip_files(sql_files, zip_file_name)

        if CLEAN_FILES == True:
            remove_files(sql_files)

        s3_client = get_s3_client(env)
        upload_file_s3(s3_client, bucket_name, database, zip_file_name)

        if CLEAN_FILES == True:
            remove_files([zip_file_name])
