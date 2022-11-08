#!/bin/bash

# to prevent filesystem corruption, clean up multi-arch binary format handlers from the host prior to
# saving updated cache
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
