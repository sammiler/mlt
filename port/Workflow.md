
***


### The Ultimate Solution for the CI Workflow

This solution combines the "environment variable" technique we discussed earlier but applies it automatically within the context of CI.

#### 1. Maintain a Flexible `portfile.cmake`

The `if/else` structure in the `portfile.cmake` is still the perfect approach. We'll continue to use it.

**`vcpkg-ports/mlt/portfile.cmake`**:
```cmake
# If the VCPKG_MLT_SOURCE_DIR environment variable exists, use the local source
if(DEFINED ENV{VCPKG_MLT_SOURCE_DIR})
    message(STATUS "CI MODE: Using local source for mlt from $ENV{VCPKG_MLT_SOURCE_DIR}")
    set(SOURCE_PATH "$ENV{VCPKG_MLT_SOURCE_DIR}")
else()
    # Otherwise, for the end-user, follow the standard download process
    # Note: The REPO and REF here should point to an official, stable version
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO mltframework/mlt
        REF v7.22.0 # Point to a released tag
        SHA512 ... # The hash corresponding to this tag
    )
endif()

# ... The rest of the build steps remain the same ...
```
*   **Key Point**: The `else` block defines the behavior for **end-users** installing this port (downloading a stable, released version). The `if` block provides a "backdoor" for our CI.

#### 2. Inject the Environment Variable in the GitHub Actions Workflow

Now, we'll configure the CI YAML file. We instruct the workflow: "Before you run `vcpkg install`, please set the `VCPKG_MLT_SOURCE_DIR` environment variable to point to the code you just checked out."

**`.github/workflows/build-vcpkg-windows.yml` (Final Version)**:
```yaml
name: 'Build MLT on Windows via vcpkg'

on: [push, pull_request]

jobs:
  build:
    runs-on: windows-latest
    
    steps:
      # Step 1: Check out the PR's code
      # This downloads all files (including vcpkg-ports) to the GITHUB_WORKSPACE directory
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Prepare vcpkg
      - name: Bootstrap vcpkg
        uses: microsoft/vcpkg-tool@v1
        with:
          vcpkgDirectory: ${{ runner.temporary }}/vcpkg
          vcpkgGitCommitId: '9999066f12f369527f7813a1d2e11a1d95b533e4'

      # Step 3: Install MLT using the Overlay Port
      - name: Install MLT using local source in CI
        run: |
          vcpkg install --triplet x64-windows --overlay-ports=${{ github.workspace }}/vcpkg-ports mlt[...]
        env:
          VCPKG_ROOT: ${{ runner.temporary }}/vcpkg
          # The magic happens here! We set the special environment variable.
          # github.workspace is the default path where actions/checkout places the code.
          VCPKG_MLT_SOURCE_DIR: ${{ github.workspace }}
```

### How This Workflow Solves the Self-Bootstrapping Problem

1.  When a PR is submitted, the CI workflow starts.
2.  `actions/checkout` downloads all the code from the PR (including the latest, un-merged `portfile.cmake`) to a directory on the virtual machine, e.g., `D:\a\mlt\mlt` (which is `${{ github.workspace }}`).
3.  The `vcpkg install` command is executed.
4.  Before it runs, the `env:` block sets the environment variable `VCPKG_MLT_SOURCE_DIR` to the value of `D:\a\mlt\mlt`.
5.  vcpkg begins processing the `mlt` port.
6.  The `if(DEFINED ENV{VCPKG_MLT_SOURCE_DIR})` condition in `portfile.cmake` evaluates to **true**.
7.  It **completely skips** the `vcpkg_from_github` block, avoiding the `SHA512` problem entirely.
8.  It directly uses the source code at `${{ github.workspace }}` (the PR's own code) for the build.

**This solution perfectly achieves:**

*   **The CI can test the code from the PR itself**, including any modifications to the `portfile.cmake`.
*   **The self-bootstrapping problem in CI is completely avoided.**
*   **End-users** who install this port on their own machines (who won't have the environment variable set) will follow the `else` path, downloading a stable, hash-verified official version, which ensures security and reproducibility.

This is a professional and robust CI practice that perfectly resolves the "chicken-and-egg" paradox you identified.