#!/bin/bash
set -e

env

#PROJECT=$(basename $(dirname $(readlink -f $0)))
SCRIPT_NAME=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
PROJECT=$(cd $(dirname "$0") && pwd);

go generate

NAMES=$(ls -d cmd/* | xargs -n1 basename)
for NAME in $NAMES; do
	OSES=${OSS:-"linux darwin windows"}
	ARCHS=${ARCHS:-"amd64 386"}
	for ARCH in $ARCHS; do
		for OS in $OSES; do
			echo $OS $ARCH $NAME
			GOOS=${OS} GOARCH=${ARCH} CGO_ENABLED=1 GOARM=7 go build -o build/${NAME}-${OS}-${ARCH} cmd/${NAME}/*.go
			if [ $? -eq 0 ]; then
				echo OK
			fi
			if [ "$OS" == "windows" ]; then
				mv build/${NAME}-${OS}-${ARCH} build/${NAME}-${OS}-${ARCH}.exe
			fi
		done
	done
done

echo "Resulting files:"
find build -type f
