#!/usr/bin/env bash

ORIGARGS=("$@")

. scripts/env.sh

helpFunction() {
	echo "Usage: $0 <geth | ganache> <http | ws> [node | electron | firefox | chrome]"
	exit 1 # Exit script after printing help
}

BACKEND=${ORIGARGS[0]}
MODE=${ORIGARGS[1]}
ENGINE=${ORIGARGS[2]}

SUPPORTED_BACKENDS=("geth" "ganache" "ipc")
SUPPORTED_MODE=("http" "ws" "ipc")
SUPPORTED_ENGINES=("node" "electron" "firefox" "chrome" "ipc" "")

if [[ ! " ${SUPPORTED_BACKENDS[*]} " =~ " ${BACKEND} " ]]; then
	helpFunction
fi

if [[ ! " ${SUPPORTED_MODE[*]} " =~ " ${MODE} " ]]; then
	helpFunction
fi

if [[ ! " ${SUPPORTED_ENGINES[*]} " =~ " ${ENGINE} " ]]; then
	helpFunction
fi

echo "Node software used for tests: " $BACKEND
echo "Node running on: " "$MODE://localhost:$WEB3_SYSTEM_TEST_PORT"

export WEB3_SYSTEM_TEST_PROVIDER="$MODE://localhost:$WEB3_SYSTEM_TEST_PORT"
export WEB3_SYSTEM_TEST_BACKEND=$BACKEND

TEST_COMMAND=""

if [[ $ENGINE == "node" ]] || [[ $ENGINE == "" ]]; then
	TEST_COMMAND="test:integration"
else if [[ $ENGINE == "ipc" ]]; then
    export WEB3_SYSTEM_TEST_PROVIDER=$(pwd)/scripts/ipc
    TEST_COMMAND="test:integration:ipc"
else
	TEST_COMMAND="lerna run test:e2e:$ENGINE --stream"
fi fi

yarn "$BACKEND:start:background" && yarn $TEST_COMMAND && yarn "$BACKEND:stop"