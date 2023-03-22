#!/bin/bash
mitmdump -s "$(dirname "$(realpath "$0")")/adblocker/adblocker.py"

