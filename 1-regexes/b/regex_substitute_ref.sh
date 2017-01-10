#!/bin/bash

PATTERN=$1
REPLACEMENT=$2

sed -E -e "s/$PATTERN/$REPLACEMENT/g"
