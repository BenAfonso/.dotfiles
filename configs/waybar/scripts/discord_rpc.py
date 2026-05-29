#!/usr/bin/env python3
import os
import sys
import json
import time
import fcntl
import requests
from pypresence.client import (
    Client,
)  # pypresence lacks __all__; direct import silences Pyright

_SECRETS_PATH = os.path.expanduser("~/.dotfiles/private/discord_rpc_secrets.json")
try:
    with open(_SECRETS_PATH) as f:
        _secrets = json.load(f)
    CLIENT_ID = _secrets["client_id"]
    CLIENT_SECRET = _secrets["client_secret"]
except Exception as e:
    raise SystemExit(f"secrets unavailable ({_SECRETS_PATH}): {e}")
TOKEN_PATH = os.path.expanduser("~/.cache/discord_waybar_token.json")
SCOPES = ["rpc", "rpc.voice.read"]

LOCK_PATH = "/tmp/discord_rpc.lock"
STATE_PATH = "/tmp/discord_rpc_state.json"


def get_authenticated_client():
    rpc = Client(CLIENT_ID)
    rpc.start()

    if os.path.exists(TOKEN_PATH):
        try:
            with open(TOKEN_PATH, "r") as f:
                token_data = json.load(f)
            res = rpc.authenticate(token_data["access_token"])
            me = token_data.get("me") or res["data"]["user"]["username"]
            if not token_data.get("me"):
                token_data["me"] = me
                with open(TOKEN_PATH, "w") as f:
                    json.dump(token_data, f)
            return rpc, me
        except Exception:
            pass

    auth_response = rpc.authorize(CLIENT_ID, SCOPES)
    code = auth_response["data"]["code"]

    response = requests.post(
        "https://discord.com/api/oauth2/token",
        data={
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "http://localhost",
        },
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )

    if response.status_code == 200:
        token_data = response.json()
        os.makedirs(os.path.dirname(TOKEN_PATH), exist_ok=True)
        res = rpc.authenticate(token_data["access_token"])
        try:
            token_data["me"] = res["data"]["user"]["username"]
        except Exception:
            pass
        with open(TOKEN_PATH, "w") as f:
            json.dump(token_data, f)
        me = token_data.get("me")
        return rpc, me
    else:
        raise RuntimeError(f"OAuth2 Token exchange failed: {response.text}")


def get_status(rpc, me):
    try:
        res = rpc.get_selected_voice_channel()

        if not res or not res.get("data"):
            return {
                "text": "",
                "tooltip": "Not in a voice channel",
                "class": "disconnected",
            }

        data = res["data"]
        channel_name = data.get("name", "Voice Channel")
        voice_states = data.get("voice_states", [])
        all_users = [
            state.get("user", {}).get("username", "Unknown") for state in voice_states
        ]
        others = [u for u in all_users if u != me] if me else all_users

        if len(others) == 1:
            text = f"󰙯 {channel_name} · {others[0]}"
        else:
            text = f"󰙯 {channel_name} ({len(voice_states)})"

        return {"text": text, "tooltip": ", ".join(all_users), "class": "connected"}
    except Exception as e:
        return {"text": "", "tooltip": f"RPC Error: {str(e)}", "class": "fatal_close"}


if __name__ == "__main__":
    rpc_client = None
    current_user = None
    lock_file = open(LOCK_PATH, "w")

    while True:
        try:
            fcntl.lockf(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
            is_leader = True
        except IOError:
            is_leader = False

        if is_leader:
            if rpc_client is None:
                try:
                    rpc_client, current_user = get_authenticated_client()
                except Exception as e:
                    fallback_err = {
                        "text": "",
                        "tooltip": f"Discord link offline: {e}",
                        "class": "disconnected",
                    }
                    print(json.dumps(fallback_err), flush=True)
                    time.sleep(3)
                    continue

            status_payload = get_status(rpc_client, current_user)

            try:
                with open(STATE_PATH, "w") as f:
                    json.dump(status_payload, f)
            except Exception:
                pass

            print(json.dumps(status_payload), flush=True)

            if status_payload["class"] == "fatal_close":
                sys.exit(1)

            time.sleep(1)

        else:
            if rpc_client is not None:
                try:
                    rpc_client.close()
                except Exception:
                    pass
                rpc_client = None

            try:
                with open(STATE_PATH, "r") as f:
                    cached_payload = json.load(f)
                print(json.dumps(cached_payload), flush=True)
            except (FileNotFoundError, json.JSONDecodeError):
                print(
                    json.dumps(
                        {"text": "", "tooltip": "Syncing...", "class": "disconnected"}
                    ),
                    flush=True,
                )

            time.sleep(0.2)
