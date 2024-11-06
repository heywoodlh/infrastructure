#!/usr/bin/env bash
set -e
onepassword_item="ohelo3flfw26d3ddenrssvdxqq"
WIREGUARD_ENDPOINT=$(op read "op://Automation/$onepassword_item/WIREGUARD_ENDPOINT")
WIREGUARD_ENDPOINT_PUBKEY=$(op read "op://Automation/$onepassword_item/WIREGUARD_ENDPOINT_PUBKEY")
WIREGUARD_PRIVKEY=$(op read "op://Automation/$onepassword_item/WIREGUARD_PRIVKEY")
WIREGUARD_ADDRESS=$(op read "op://Automation/$onepassword_item/WIREGUARD_ADDRESS")
TS_AUTHKEY=$(op read "op://Automation/$onepassword_item/TS_AUTHKEY")

#echo "WIREGUARD_ENDPOINT: ${WIREGUARD_ENDPOINT}"
#echo "WIREGUARD_ENDPOINT_PUBKEY: ${WIREGUARD_ENDPOINT_PUBKEY}"
#echo "WIREGUARD_PRIVKEY: ${WIREGUARD_PRIVKEY}"
#echo "WIREGUARD_ADDRESS: ${WIREGUARD_ADDRESS}"
#echo "TS_AUTHKEY: ${TS_AUTHKEY}"

fly secrets set \
    WIREGUARD_ENDPOINT="${WIREGUARD_ENDPOINT}" \
    WIREGUARD_ENDPOINT_PUBKEY="${WIREGUARD_ENDPOINT_PUBKEY}" \
    WIREGUARD_PRIVKEY="${WIREGUARD_PRIVKEY}" \
    WIREGUARD_ADDRESS="${WIREGUARD_ADDRESS}" \
    TS_AUTHKEY="${TS_AUTHKEY}"
