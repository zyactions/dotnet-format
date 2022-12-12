#!/usr/bin/env bash

set -e

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

cmd="dotnet format '$INPUT_WORKSPACE'"

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
