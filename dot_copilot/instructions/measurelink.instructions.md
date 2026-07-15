---
description: MeasureLINK-MCS project conventions. Loads for any C# source, csproj, or ApplicationPacks file in the MeasureLINK-MCS solution.
applyTo: "MeasureLINK-MCS*/**/*.{cs,csproj,xaml,py,json,md}"
---

# MeasureLINK-MCS Project Rules

## Solution shape

Large multi-project C# solution. Many shared APIs have many callers. Default to additive, localized changes. Match existing patterns; extend rather than introduce.

## Implementation Notes

- When implementing something related to a Model, make sure to update Equals, Copy, and GetHashCode as needed.

## Versioning

Version numbers must be updated before production code or application-pack changes are considered complete.

NOTE: Versions for test-only, docs-only, and tooling-only changes do not need to be updated unless they affect packaged outputs.

1. **AssemblyFileVersion:** Update for any changes to the project.
2. **AssemblyVersion:** Update only if public API surfaces were modified (new/changed public types, methods, or interfaces).
3. If `AssemblyFileVersion` or `AssemblyVersion` don't exist in the project, update the relevant `.csproj` instead.
4. For changes to application packs, update the manifest file by adding a line with the current version and a short description. Manifest files and the Python scripts defining pack contents live in the `ApplicationPacks` directory.
5. If the user hasn't provided a version number, **ask for it**
