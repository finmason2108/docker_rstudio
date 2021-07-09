#!/bin/sh

# stop when error occurs
set -e

### Default values to variables
AWS_REGION=${AWS_REGION:-us-east-1}
ENVIRONMENT=${ENVIRONMENT:-DEV}
AWS_DEFAULT_REGION=$AWS_REGION

export ENVIRONMENT
export AWS_DEFAULT_REGION
export AWS_REGION

### Entrypoint.d located configurations
if /usr/bin/find "/entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "$0: /entrypoint.d/ is not empty, will attempt to perform configuration"

    echo "$0: Looking for shell scripts in /entrypoint.d/"
    find "/entrypoint.d/" -follow -type f -print | sort -n | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo "$0: Ignoring $f, not executable";
                fi
                ;;
            *.py)
                echo "$0: Launching $f";
                python3 "$f"
                ;;
            *) echo "$0: Ignoring $f";;
        esac
    done

    echo "$0: Configuration complete; ready for start up"
else
    echo "$0: No files found in /entrypoint.d/, skipping configuration"
fi

### exec
echo "****************************"
exec "$@"
