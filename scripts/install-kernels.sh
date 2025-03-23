#!/usr/bin/env bash
set -eu

[ -z "$SCALA_VERSIONS" ] && { echo "SCALA_VERSIONS is empty" ; exit 1; }
[ -z "$ALMOND_VERSION" ] && { echo "ALMOND_VERSION is empty" ; exit 1; }
SCALA_VERSIONS_CLEANED=$(echo "$SCALA_VERSIONS" | sed 's/-\([0-9]\)/ \1/g')
for SCALA_FULL_VERSION in ${SCALA_VERSIONS_CLEANED}; do
  # remove patch version
  SCALA_MAJOR_VERSION=${SCALA_FULL_VERSION%.*}
  # remove all dots for the kernel id
  SCALA_MAJOR_VERSION_TRIMMED=$(echo ${SCALA_MAJOR_VERSION} | tr -d .)
  echo Installing almond ${ALMOND_VERSION} for Scala ${SCALA_FULL_VERSION}
  EXTRA_ARGS=()
  if [[ ${ALMOND_VERSION} == *-SNAPSHOT ]]; then
    EXTRA_ARGS+=('--standalone')
  fi
  coursier bootstrap \
      -r jitpack -r central -r sonatype:snapshots -r sonatype:releases \
      -i user -I user:sh.almond:scala-kernel-api_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      sh.almond:scala-kernel_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      --default=true --sources \
      -o almond ${EXTRA_ARGS[@]} --verbose
  ./almond --install --log info --metabrowse --id scala${SCALA_MAJOR_VERSION_TRIMMED} --display-name "Scala ${SCALA_MAJOR_VERSION}" --force
  rm -f almond
done
echo Installation was successful
