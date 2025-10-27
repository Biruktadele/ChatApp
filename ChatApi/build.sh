#!/usr/bin/env bash
# exit on error
set -o errexit

# Add the project root to the PYTHONPATH
# export PYTHONPATH=.

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Apply database migrations
python manage.py migrate