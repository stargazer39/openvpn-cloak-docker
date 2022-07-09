import os
import sys
import json
from shutil import copy
import subprocess

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

config_path = "/config/ckserver.json"
ckjson = {
  "ProxyBook": {},
  "BindAddr": [],
  "BypassUID": [],
  "RedirAddr": "zoom.us",
  "PrivateKey": "",
  "AdminUID": "",
  "DatabasePath": "userinfo.db"
}

try:
    with open(config_path, mode='r') as ckfile:
        ckjson = json.loads(ckfile.read())
        ckfile.close()
except Exception as e:
    eprint(e)

port = "444"

try:
    port = os.environ["PORT"]
except Exception as e:
    eprint("No PORT in environment vars")
    eprint(e)

try:
    ckjson["ProxyBook"] = json.loads(os.environ["PROXY_BOOK"])
except Exception as e:
    eprint("No PORT in environment vars")
    eprint(e)

try:
    ckjson["RedirAddr"] = os.environ["SPOOF_ADDRESS"]
except Exception as e:
    eprint("No SPOOF_ADDRESS in environment vars")
    eprint(e)


if os.path.exists(config_path) :
    eprint("Config already exists")
else:
    try:
        user_uid = os.environ["CK_BYPASSUID"]
        admin_uid = os.environ["CK_ADMINUID"]
        private_key = os.environ["CK_PRIVATEKEY"]

        # Build config according to environment variables
        with open(config_path, mode='w') as config :
            ckjson["BypassUID"].append(user_uid)
            ckjson["AdminUID"] = admin_uid
            ckjson["PrivateKey"] = private_key
            ckjson["BindAddr"].append(f":{port}")

            ck_json_string =  json.dumps(ckjson, indent=4)
            print(ck_json_string, file=config)
            config.close()
        eprint("Config generated from environment variables..")
    except Exception as e:
        eprint(e)
        eprint("Variables not found. Trying to make a configuration...")

        # Get keys for ck-server
        keys = subprocess.check_output(["ck-server", "-key"]).decode().split("\n")
        public_key = keys[0][-44:]
        private_key = keys[1][-44:]

        # Generate UIDs
        admin_uid = subprocess.check_output(["ck-server", "-uid"]).decode().strip()
        admin_uid = admin_uid[-24:]

        user_uid = subprocess.check_output(["ck-server", "-uid"]).decode().strip()
        user_uid = user_uid[-24:]

        eprint("Admin ", admin_uid)
        eprint("User ", user_uid)
        eprint("Public ", public_key)
        #print("Private key ", private_key)

        # Build json file
        ckjson["BypassUID"].append(user_uid)
        ckjson["AdminUID"] = admin_uid
        ckjson["PrivateKey"] = private_key
        ckjson["BindAddr"].append(f":{port}")

        with open("/config/keys.json", mode='w') as keys:
            service = {
                "Transport":"direct",
                "ProxyMethod": "openvpn",
                "EncryptionMethod": "plain",
                "UID": user_uid,
                "PublicKey": public_key,
                "ServerName": "zoom.us",
                "NumConn": 16,
                "BrowserSig": "chrome",
                "StreamTimeout": 300,
                "KeepAlive":120
            }

            keys_json = {
                "publicKey": public_key,
                "adminUid": admin_uid,
                "userUid": user_uid,
            }
            
            keys_string = json.dumps(keys_json, indent=4)
            sevice_string = json.dumps(service, indent=4)

            print(keys_string, file=keys)

            with open("/config/ckclient-zoom.json", mode='w') as ckc:
                print(sevice_string, file=ckc)

with open(config_path, mode='w') as config :
    ck_json_string =  json.dumps(ckjson, indent=4)
    print(ck_json_string, file=config)

# Start all processes etc.
ck_server = subprocess.Popen(["ck-server","-c","/config/ckserver.json"])
ck_server.wait()
eprint("Script exited.")