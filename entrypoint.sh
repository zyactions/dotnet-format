#!/usr/bin/env bash

set -e
set -o pipefail

if [[ "$INPUT_INCLUDE" == '-' ]] || [[ "$INPUT_EXCLUDE" == '-' ]]; then
    if [[ -z "$INPUT_PIPE" ]]; then
        echo "::error ::The 'pipe' input is required in order to read from the standard input"
        exit 1
    fi
    if [[ "$INPUT_INCLUDE" == '-' ]] && [[ "$INPUT_EXCLUDE" == '-' ]]; then
        echo "::error ::The 'include' and 'exclude' lists can not be read from the standard" \
            "input at the same time"
        exit 1
    fi
fi

if [[ -n "$INPUT_PIPE" ]] && [[ "$INPUT_INCLUDE" != '-' ]] && [[ "$INPUT_EXCLUDE" != '-' ]]; then
    echo "::warning ::The 'pipe' input is ignored as neither 'include' nor 'exclude' is"\
        "configured to read from the standard input"
fi

if sdk_version=$(dotnet --version 2>&1); then
    echo "Using .NET SDK version '$sdk_version'"
else
    if [[ "$INPUT_USE_STANDALONE_TOOL" == "false" ]]; then
        echo "::error ::The .NET SDK is not installed"
        exit 1
    fi
fi

if [[ "$INPUT_USE_STANDALONE_TOOL" == "true" ]]; then
    cmd="dotnet-format"
else
    cmd="dotnet format"
fi

if version=$(eval "$cmd --version" 2>&1); then
    echo "Using 'dotnet format' version '$version'"
else
    echo "::error ::The 'dotnet-format' tool is not installed"
    exit 1
fi

if [[ -n "$INPUT_WORKSPACE" ]]; then
    cmd+=" '$INPUT_WORKSPACE'"
fi

if [[ "$INPUT_IMPLICIT_RESTORE" == "false" ]]; then
    cmd+=" --no-restore"
fi

if [[ -n "$INPUT_DIAGOSTICS" ]]; then
    values=$(printf '%s\n' "$INPUT_DIAGNOSTICS" | "$GITHUB_ACTION_PATH/shellquote.sh" ' ')
    cmd+=" --diagnostics $values"
fi
if [[ -n "$INPUT_SEVERITY" ]]; then
    cmd+=" --severity '$INPUT_SEVERITY'"
fi
if [[ "$INPUT_VERIFY_NO_CHANGES" == "true" ]]; then
    cmd+=" --verify-no-changes"
fi

if [[ -n "$INPUT_INCLUDE" ]]; then
    if [[ "$INPUT_INCLUDE" == '-' ]]; then
        cmd+=" --include -"
        cmd="$INPUT_PIPE | $cmd"
    else
        files=$(printf '%s\n' "$INPUT_INCLUDE" | "$GITHUB_ACTION_PATH/shellquote.sh" ' ')
        cmd+=" --include $files"
    fi
fi
if [[ -n "$INPUT_EXCLUDE" ]]; then
    if [[ "$INPUT_EXCLUDE" == '-' ]]; then
        cmd+=" --exclude -"
        cmd="$INPUT_PIPE | $cmd"
    else
        files=$(printf '%s\n' "$INPUT_EXCLUDE" | "$GITHUB_ACTION_PATH/shellquote.sh" ' ')
        cmd+=" --exclude $files"
    fi
fi

if [[ -n "$INPUT_REPORT_PATH" ]]; then
    cmd+=" --report '$INPUT_REPORT_PATH'"
fi

eval "$cmd"
