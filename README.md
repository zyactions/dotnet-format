# .NET Format

![License: MIT][shield-license-mit]
[![CI][shield-ci]][workflow-ci]
[![Ubuntu][shield-platform-ubuntu]][job-runs-on]
[![macOS][shield-platform-macos]][job-runs-on]
[![Windows][shield-platform-windows]][job-runs-on]

A GitHub Action that wraps the .NET CLI `dotnet format` command. 

## Features

- Wraps the `dotnet format` [.NET CLI][dotnet-sdk] command
  - Provides a structured way of using this command in a workflow
- Supports all platforms (Linux, macOS, Windows)
- No external GitHub Actions dependencies

> **Note**
>
> This action provides a wrapper around the `dotnet format` [.NET CLI][dotnet-sdk] command. 
> For further details, please check out the [official documentation][dotnet-format].

## Usage

### Format

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: .NET Format
    uses: zyactions/dotnet-format@v1
    with:
      workspace: test
      implicit-restore: true
```

> **Note**
>
> Unlike the wrapped command, this action does not perform an implicit package restore by default. A manual package restore (e.g. using [zyactions/dotnet-restore][zyactions-dotnet-restore]) is required by design.
>
> Set `implicit-restore` to `true` to switch back to the original behavior.

### Format a specific Project- or Solution

```yaml
steps:
steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: .NET Format
    uses: zyactions/dotnet-format@v1
    with:
      workspace: test/Test.csproj
      implicit-restore: true
```

### Format only specific Files using a Glob Pattern

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: Glob Match
    id: glob
    uses: zyactions/glob@v2
    with:
      pattern: |
        test/*.cs
        !test/*.AutoGenerated.cs
      return-pipe: true

  - name: .NET Format
    uses: zyactions/dotnet-format@v1
    with:
      workspace: test/Test.csproj
      include: '-'
      pipe: ${{ steps.glob.outputs.pipe }}
      implicit-restore: true
```

> **Note**: Check out the [zyactions/glob][zyactions-glob] action for further details.

### Check Formatting without performing Changes

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v3

  - name: .NET Format
    uses: zyactions/dotnet-format@v1
    with:
      workspace: test
      verify-no-changes: true
      implicit-restore: true
```

> **Note**
>
> Check out the [zyactions/dotnet-lint][zyactions-dotnet-lint] action action if you like to create pull request annotations for detected formatting violations.

## Inputs

### `working-directory`

The working-directory for the action.

Defaults to the repository root directory (`github.workspace`).

> **Note**
>
> If a specific .NET SDK version is to be used, the working directory must point to the directory that contains the `global.json` or a subdirectory of it.

### `workspace`

The Visual Studio workspace (directory, project- or solution-file).

The `dotnet restore` command automatically searches for a Visual Studio Solution file (`*.sln`) in the specified workspace directory, if no explicit solution- or project- file is specified.

Example values:

- `path/to/workspace`
- `path/to/Solution.sln`
- `path/to/Project.csproj`

### `diagnostics`

A newline-separated list of diagnostic IDs to use as a filter when fixing code style or third-party issues. Default value is whichever IDs are listed in the `.editorconfig` file. For a list of built-in analyzer rule IDs that you can specify, see the [list of IDs for code-analysis style rules][style-rules].

### `severity`

The minimum severity of diagnostics to fix. Allowed values are `info`, `warn`, and `error`. The default value is `warn`.

### `verify-no-changes`

Verifies that no formatting changes would be performed. Terminates with a non zero exit code if any files would have been formatted.

### `include`

A newline-separated list of relative file or folder paths to include in formatting. The default is all files in the solution or project.

Use `-` to read the list of files from the `pipe` input.

### `exclude`

A newline-separated list of relative file or folder paths to exclude from formatting.

The default is none.

Use `-` to read the list of files from the `pipe` input.

### `report-path`

Produces a JSON report in the specified directory.

### `implicit-restore`

Execute an implicit restore before formatting.

### `use-standalone-tool`

Uses the standalone version of the `dotnet-format` tool instead of the version bundled with the .NET SDK.

> **Note**
>
> Check out the instructions for [installing a development build][dotnet-format-dev-builds] of `dotnet-format`.

### `pipe`

An optional pipe input from which the `include` or `exclude` filenames are to be read.

This must be set to a valid shell command line (bash) that can be used for piping. The command must output to `stdout` and separate the individual filenames by line breaks.

> **Warning**
>
> The command passed to this input will be evaluated and should not come from untrusted sources.

## Requirements

The [.NET CLI][dotnet-sdk] needs to be installed on the runner. To be independent from the GitHub defaults, it's recommended to install a specific version of the SDK prior to calling this action.

To install the .NET SDK in your workflow, the following actions can be used:

- [zyactions/dotnet-setup][zyactions-dotnet-setup]
- [actions/setup-dotnet][actions-setup-dotnet]

## Dependencies

This action does not use external GitHub Actions dependencies.

## Versioning

Versions follow the [semantic versioning scheme][semver].

## License

.NET Format Action is licensed under the MIT license.

[actions-setup-dotnet]: https://github.com/actions/setup-dotnet
[dotnet-format]: https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format
[dotnet-format-dev-builds]: https://github.com/dotnet/format#how-to-install-development-builds
[dotnet-sdk]: https://github.com/dotnet/sdk
[job-runs-on]: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idruns-on
[semver]: https://semver.org
[shield-license-mit]: https://img.shields.io/badge/License-MIT-blue.svg
[shield-ci]: https://github.com/zyactions/dotnet-format/actions/workflows/ci.yml/badge.svg
[shield-platform-ubuntu]: https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu\&logoColor=white
[shield-platform-macos]: https://img.shields.io/badge/macOS-53C633?logo=apple\&logoColor=white
[shield-platform-windows]: https://img.shields.io/badge/Windows-0078D6?logo=windows\&logoColor=white
[style-rules]: https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules
[workflow-ci]: https://github.com/zyactions/dotnet-format/actions/workflows/ci.yml
[zyactions-dotnet-lint]: https://github.com/zyactions/dotnet-lint
[zyactions-dotnet-restore]: https://github.com/zyactions/dotnet-restore
[zyactions-dotnet-setup]: https://github.com/zyactions/dotnet-setup
[zyactions-glob]: https://github.com/zyactions/glob
