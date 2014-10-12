#!/usr/bin/env bash

set -e
set -u

readonly TMUX_BIN="$(type -P tmux)"
readonly SSH_PORT_FORWARD=${SSH_PORT_FORWARD:-999}
readonly GENERIC_NAME=tmux-demo-port-"${SSH_PORT_FORWARD}"
readonly LIBC6_LIB="$(ldd "${TMUX_BIN}" | awk '/libc.so.6/{print $3}')"

# Make sure that tmux is installed.
if [[ -z "${TMUX_BIN}" ]]; then
    echo "tmux binary not found..." >&2
    echo "Exiting..." >&2
    exit 1
fi

readonly TEMP_DIR="$(mktemp -d)"

echo "Copying tmux and libc to temporary location..."
cp -f "${TMUX_BIN}" "${TEMP_DIR}"/tmux
cp -f "${LIBC6_LIB}" "${TEMP_DIR}"/libc.so.6

echo "Creating tmux session called ${GENERIC_NAME}..."
tmux -S "${TEMP_DIR}/${GENERIC_NAME}" \
    new-session -d \
    -s "${GENERIC_NAME}"

echo "Creating docker instance..."
docker run \
    --name "${GENERIC_NAME}" \
    -p "${SSH_PORT_FORWARD}:22" \
    -v "${TEMP_DIR}/tmux:/usr/local/bin/tmux" \
    -v "${TEMP_DIR}/libc.so.6:/usr/local/lib/libc.so.6" \
    -v "${TEMP_DIR}/${GENERIC_NAME}:/var/lib/tmux-sessions/guest" \
    tmux-guest

echo "Destroying docker instance..."
docker rm "${GENERIC_NAME}"

echo "Destroying tmux session..."
tmux -S "${TEMP_DIR}/${GENERIC_NAME}" \
    kill-session \
    -t "${GENERIC_NAME}"

echo "Removing temporary files..."
rm -rf "${TEMP_DIR}"
