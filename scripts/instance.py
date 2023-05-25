# Script to build all configured instances

import json
import os
import shutil

# make sure we're not inside the scripts dir
if os.getcwd().endswith("scripts"):
    os.chdir("..")

# try to make sure SM is built first?
if not os.path.exists("build") or not os.path.exists("build/_sm"):
    print("make sm first before running instance.py")

# remove old instances
if os.path.exists("build/_instances"):
    shutil.rmtree("build/_instances")
os.mkdir("build/_instances")

# get instances list
instances: dict
with open("cfg/inventory.json", "r") as inventory:
    instances = json.loads(inventory.read())
print(
    f"Found {len(instances.keys())} instance{'' if len(instances.keys()) == 1 else 's'}:\n{', '.join(instances.keys())}\n"
)

# create instance configs
for i_name, i_data in instances.items():
    print(f"{i_name} - Starting...")
    os.mkdir(f"build/_instances/{i_name}")
    os.mkdir(f"build/_instances/{i_name}/tf")

    # copy sourcemod
    print(f"{i_name} - Copying SourceMod...")
    shutil.copytree("build/_sm", f"build/_instances/{i_name}/tf", dirs_exist_ok=True)

    # copy common config
    print(f"{i_name} - Copying common config...")
    shutil.copytree("cfg/all/", f"build/_instances/{i_name}/", dirs_exist_ok=True)
    shutil.copytree(
        "secret/cfg/all/", f"build/_instances/{i_name}/", dirs_exist_ok=True
    )

    # copy instance config if applicable
    print(f"{i_name} - Copying instance config...")
    if os.path.exists(f"cfg/{i_name}"):
        shutil.copytree(
            f"cfg/{i_name}/", f"build/_instances/{i_name}/", dirs_exist_ok=True
        )
    if os.path.exists(f"secret/cfg/{i_name}"):
        shutil.copytree(
            f"secret/cfg/{i_name}/", f"build/_instances/{i_name}/", dirs_exist_ok=True
        )

    print(f"{i_name} - Complete\n")
