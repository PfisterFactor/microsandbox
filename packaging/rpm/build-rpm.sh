#!/usr/bin/env bash
# Build a microsandbox RPM inside a Fedora container.
#
# Expects the following env vars (set by the workflow):
#   RPM_VERSION   — e.g. 0.3.14
#   RPM_BUILDNUM  — monotonic integer, e.g. UTC epoch
#   RPM_SHORTSHA  — 7-char git short sha
#   GH_OWNER      — github owner/user (e.g. PfisterFactor)
#   HOST_UID      — runner UID, used to chown outputs back after rpmbuild
#   HOST_GID      — runner GID
#
# Expects these files already staged under $PWD/packaging/rpm/sources/:
#   msb, libkrunfw.so.5.2.1, LICENSE
#
# Outputs RPM(s) into $PWD/packaging/rpm/out/.

set -euo pipefail

: "${RPM_VERSION:?}"
: "${RPM_BUILDNUM:?}"
: "${RPM_SHORTSHA:?}"
: "${GH_OWNER:?}"
: "${HOST_UID:?}"
: "${HOST_GID:?}"

dnf install -y --setopt=install_weak_deps=False rpm-build >/dev/null

WORK=$(pwd)
TOPDIR="${WORK}/packaging/rpm/rpmbuild"
SOURCES="${WORK}/packaging/rpm/sources"
OUT="${WORK}/packaging/rpm/out"

rm -rf "${TOPDIR}" "${OUT}"
mkdir -p "${TOPDIR}"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} "${OUT}"

cp "${SOURCES}/msb"                "${TOPDIR}/SOURCES/msb"
cp "${SOURCES}/libkrunfw.so.5.2.1" "${TOPDIR}/SOURCES/libkrunfw.so.5.2.1"
cp "${SOURCES}/LICENSE"            "${TOPDIR}/SOURCES/LICENSE"
cp "${WORK}/packaging/rpm/microsandbox.spec" "${TOPDIR}/SPECS/microsandbox.spec"

rpmbuild \
    --define "_topdir ${TOPDIR}" \
    --define "_version ${RPM_VERSION}" \
    --define "_buildnum ${RPM_BUILDNUM}" \
    --define "_shortsha ${RPM_SHORTSHA}" \
    --define "_owner ${GH_OWNER}" \
    --define "_changelog_date $(LC_ALL=C date -u '+%a %b %d %Y')" \
    -bb "${TOPDIR}/SPECS/microsandbox.spec"

find "${TOPDIR}/RPMS" -name '*.rpm' -exec cp -v {} "${OUT}/" \;

chown -R "${HOST_UID}:${HOST_GID}" "${TOPDIR}" "${OUT}"

ls -lh "${OUT}/"
