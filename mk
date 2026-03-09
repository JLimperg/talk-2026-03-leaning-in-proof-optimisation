#!/bin/bash
set -euo pipefail

TEX=talk.tex
if [[ "${1:-}" == "--handout" ]]; then
  TEX=talk-handout.tex
  shift
fi

ROOT="$(realpath "$(dirname "$0")")"

for cmd in docker podman finch; do
  if command -v "$cmd" &>/dev/null; then
    RUNTIME="$cmd"
    break
  fi
done

if [[ -z "${RUNTIME:-}" ]]; then
  echo "Error: no container runtime found (tried docker, podman, finch)" >&2
  exit 1
fi

"$RUNTIME" run --rm \
  --mount=type=bind,source="$ROOT",destination=/work \
  --workdir /work \
  registry.gitlab.com/islandoftex/images/texlive:TL2025-2026-01-18-full \
  latexmk -pdf -xelatex -recorder \
  -latexoption="-interaction nonstopmode" \
  -outdir=build "$TEX" "$@"
