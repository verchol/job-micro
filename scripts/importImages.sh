#!/bin/bash

set -e

# $IMAGES - list of comma separated image names (with tags)
# $REGISTRY - registry DNS name (including port if needed)
# $USERNAME - Docker registry user name
# $PASSWORD - Docker registry password
# $REGISTRY - Docker registry DNS name (including port, if needed)

# CF_URL - Codefresh API URL (+ api/images/external)
# CF_API_TOKEN - Codefresh API Token


# set array with all images
images=(${IMAGES//,/ })

if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
  creds_flag="--creds $USERNAME:$PASSWORD"
fi

registry=${REGISTRY:-docker.io}

for image in "${images[@]}"; do
  # get image details from registry
  skopeo inspect ${creds_flag} docker://"$registry/$image" | \
    jq --arg name "$registry/$image" '.=.+{Image: $name}' | jq . > metadata.json
  echo "Successfuly fetched metadata for $image image"
  # import external image to CF
  curl \
    -H "Content-Type: application/json" \
    -H "x-access-token: $CF_API_TOKEN" \
    -POST \
    -d @metadata.json \
    "$CF_URL/api/images/external"
  echo "Successfuly imported the $image image into CodeFresh"
  
done
