# Script to build configurations for all configured instances

import json
import os
import shutil

# make sure we're not inside the scripts dir
if os.getcwd().endswith("scripts"):
    os.chdir("..")

# try to make sure SM is built first?
if not os.path.exists("build") or not os.path.exists("build/_sm"):
    print("make sm first before running config.py")

# remove old instances
if os.path.exists("build/_instances"):
    shutil.rmtree("build/_instances")
os.mkdir("build/_instances")

# get instances list
instances: dict
with open("cfg/inventory.json", "r") as inventory:
    instances = json.loads(inventory.read())

# create instance configs
for i_name, i_data in instances.items():
    os.mkdir(f"build/_instances/{i_name}")

    # copy common config
    shutil.copytree("cfg/all/", f"build/_instances/{i_name}/", dirs_exist_ok=True)
    shutil.copytree(
        "secret/cfg/all/", f"build/_instances/{i_name}/", dirs_exist_ok=True
    )

    # copy instance config if applicable
    if os.path.exists(f"cfg/{i_name}"):
        shutil.copytree(
            f"cfg/{i_name}/", f"build/_instances/{i_name}/", dirs_exist_ok=True
        )
    if os.path.exists(f"secret/cfg/{i_name}"):
        shutil.copytree(
            f"secret/cfg/{i_name}/", f"build/_instances/{i_name}/", dirs_exist_ok=True
        )
