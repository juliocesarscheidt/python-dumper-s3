import os
import sys
import pickle

from sqlalchemy import create_engine, text

PARALLEL_PROCESSES_NUM = int(os.environ.get("PARALLEL_PROCESSES_NUM", "4"))


def get_database_engine(secret_dict):
    username = secret_dict["username"]
    password = secret_dict["password"]
    host = secret_dict["host"]
    port = secret_dict["port"]
    uri = f"mysql+pymysql://{username}:{password}@{host}:{port}/"
    return create_engine(
        uri,
        execution_options={"isolation_level": "AUTOCOMMIT"},
        echo=True,
        pool_size=PARALLEL_PROCESSES_NUM,
        max_overflow=0,
    )


def get_tables(engine, database, from_cache=False):
    query_tables = f"""
      SELECT
        TABLE_NAME AS `table_name`,
        ROUND(data_length + index_length / 1024 / 1024, 2) AS `table_size_mb`
      FROM
        information_schema.TABLES
      WHERE
        table_schema = '{database}'
      ORDER BY
        1 ASC
    """
    rows = []
    file_name = f"cache_{database}.pkl"

    try:
        file_stat = os.stat(file_name)
        file_size = int(file_stat.st_size) / 1024 / 1024
        print("[INFO] Cache file Size %.2f MB" % file_size)
        has_cache_file = True
    except Exception as e:
        has_cache_file = False

    if from_cache == True and has_cache_file == True:
        print("[INFO] Retrieving file from cache")
        infile = open(file_name, "rb")
        rows = pickle.load(infile)
        infile.close()

    if from_cache == False or has_cache_file == False:
        try:
            with engine.connect() as conn:
                rowproxy = conn.execution_options(stream_results=True).execute(
                    text(query_tables)
                )
                for row in rowproxy:
                    row = list(row)
                    rows.append(
                        {"table_name": row[0], "table_size_mb": float(row[1]),}
                    )
                # saving file for cache
                if len(rows) > 0:
                    print("[INFO] Saving file to cache")
                    outfile = open(file_name, "wb")
                    pickle.dump(rows, outfile)
                    outfile.close()
        except Exception as e:
            print(e)
            sys.exit(1)

    return rows
