#!/usr/bin/env bash
set -e
onepassword_item="hsietragqaggn7qq624hglu5pu"
TS_AUTHKEY=$(op read "op://Automation/$onepassword_item/TS_AUTHKEY")

fly secrets set \
    TS_AUTHKEY="${TS_AUTHKEY}"
