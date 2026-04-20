#!/usr/bin/env bash
set -euo pipefail

# Clean DNF metadata and cache
dnf clean all

# Clean rpm-ostree cache and metadata
rpm-ostree cleanup -m