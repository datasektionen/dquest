#!/bin/bash

export MONGO_URL="localhost:27017"
cd server

stack exec server

cd ..
