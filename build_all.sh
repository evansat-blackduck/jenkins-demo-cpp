#!/bin/bash
set -e

echo "Building server..."
cd server
make
cd ..

echo "Building client..."
cd client
make
cd ..
