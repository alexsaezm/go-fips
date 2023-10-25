#!/usr/bin/env bash
# This script execute a set of steps needed by the .packit.yaml file

# Drop fedora.go file
rm -fv .packit_rpm/fedora.go
sed -i '/SOURCE2/d' .packit_rpm/golang.spec
sed -i '/fedora.go/d' .packit_rpm/golang.spec
# Drop all the patches, we don't know if they can be apply to the new code
rm -fv .packit_rpm/*.patch
sed -ri '/^Patch[0-9]*:.+$/d' .packit_rpm/golang.spec

# Detect the Go version targeted in the PR
#input=$(grep "github.com/golang/go" config/versions.json | cut -d : -f 2 | tr -d ' ' | tr -d 'go' | tr -d '"')
input=$(awk '/github.com\/golang\/go/ {gsub(/[: "go]/, "", $2); print $2}' config/versions.json)
# Split the input using '.' as the delimiter
IFS='.' read -ra parts <<< "$input"
# Extract the first two parts and store in go_api
go_api="${parts[0]}.${parts[1]}"
# Extract the third part and store in go_patch
go_patch="${parts[2]}"
# Update the Go version in golang.spec with the value of $go_api and $go_patch
sed -i "s/%global go_api .*/%global go_api $go_api/" .packit_rpm/golang.spec
sed -i "s/%global go_patch .*/%global go_patch $go_patch/" .packit_rpm/golang.spec

