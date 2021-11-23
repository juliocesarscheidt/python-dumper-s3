import os
import zipfile


def zip_files(files, zip_file_name):
    compression = zipfile.ZIP_DEFLATED
    print(f"[INFO] Creating ZIP file {zip_file_name}...")
    with zipfile.ZipFile(zip_file_name, "w") as zfile:
        for f in files:
            zfile.write(f, compress_type=compression)
        zfile.close()


def remove_files(files):
    print("[INFO] Removing files...")
    for f in files:
        os.remove(f)
