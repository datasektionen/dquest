#!/bin/bash


# Build the shared library
stack build --stack-yaml=shared/stack.yaml -j8


# Build the client
stack build --stack-yaml=client/stack.yaml -j8


# Copy over the javascript to webdata
rm -f server/static/all.js
cp $(stack path --stack-yaml=client/stack.yaml --local-install-root)/bin/client-exe.jsexe/* server/webdata/

# Build the server
stack build --stack-yaml=server/stack.yaml -j8
