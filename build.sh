#!/bin/bash
./hooks/post_checkout
./hooks/pre_build

make build
#make release VERSION=latest
#make deploy