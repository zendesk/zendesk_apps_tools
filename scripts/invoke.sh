#!/bin/bash

# When running the zat container, mount the current directory to /app
# so that zat has access to it.
docker run -it --rm -v $(pwd):/usr/src/app zat $@