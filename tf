#!/usr/bin/env bash
exec op run --env-file .env -- terraform "${@}"