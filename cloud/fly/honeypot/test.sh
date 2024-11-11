#!/usr/bin/env bash

cur_dir="$(pwd)"
mkdir -p ${cur_dir}/logs
cd ${cur_dir}/logs
touch log_auth.csv log_session.csv log_session.json
cd ${cur_dir}
docker build -t heywoodlh-testing ${cur_dir}
docker run -it --rm -v ${cur_dir}/logs:/logs -p 8000:8000 heywoodlh-testing
