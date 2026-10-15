<#
.SYNOPSIS
Prints Telerik Fluent palette values and ThemeHelper attached properties.

.DESCRIPTION
Loads the Telerik assemblies from TelerikPath, applies the requested Fluent
palette preset, and prints selected FluentPalette color and opacity values
followed by the public ThemeHelper dependency properties. Use it when
investigating third-party control styling: palette values for state colors, and
ThemeHelper properties for attached theme-helper setters.

Shows Telerik preset values only, not application overrides applied at runtime.
Assemblies missing from TelerikPath are skipped; the script then fails when it
first uses a missing type.

.PARAMETER TelerikPath
Directory containing Telerik.Windows.Controls.dll and related assemblies.
Defaults to .\lib\Telerik.NET relative to the current directory.

.PARAMETER Variation
Fluent color variation to load: Light or Dark. Defaults to Dark.

.PARAMETER SelfTest
Run both variations in separate processes and check that every palette value
and the ThemeHelper list are populated. Cannot be combined with Variation.

.EXAMPLE
pwsh -NoProfile -File "$HOME\.copilot\tools\Dump-TelerikThemeState.ps1" -TelerikPath D:\repos\Mossbauer\lib\Telerik.NET -Variation Light

.EXAMPLE
pwsh -NoProfile -File "$HOME\.copilot\tools\Dump-TelerikThemeState.ps1" -TelerikPath D:\repos\Mossbauer\lib\Telerik.NET -SelfTest
#>
param(
    [string]$TelerikPath = ".\lib\Telerik.NET",
    [ValidateSet("Light", "Dark")]
    [string]$Variation = "Dark",
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

if ($SelfTest) {
    if ($PSBoundParameters.ContainsKey("Variation")) {
        throw "-Variation cannot be combined with -SelfTest."
    }

    $resolvedSelfTestPath = (Resolve-Path -LiteralPath $TelerikPath).Path
    foreach ($selfTestVariation in "Light", "Dark") {
        $output = @(pwsh -NoProfile -File $PSCommandPath -TelerikPath $resolvedSelfTestPath -Variation $selfTestVariation 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "$selfTestVariation run failed: $($output -join [Environment]::NewLine)"
        }

        $separatorIndex = [array]::IndexOf($output, "ThemeHelper dependency properties")
        if ($output[0] -ne "FluentPalette $selfTestVariation preset" -or $separatorIndex -lt 0) {
            throw "$selfTestVariation run produced unexpected output."
        }

        $paletteLines = @($output[2..($separatorIndex - 2)])
        $emptyValues = @($paletteLines | Where-Object { $_ -notmatch '^\S+\s+\S' })
        if ($paletteLines.Count -ne 24 -or $emptyValues.Count -gt 0) {
            throw "$selfTestVariation palette is incomplete: $($emptyValues -join '; ')"
        }

        if ($output.Count -le $separatorIndex + 2) {
            throw "$selfTestVariation ThemeHelper list is empty."
        }
    }

    "Dump-TelerikThemeState self-test passed."
    return
}

function Add-AssemblyIfPresent {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Add-Type -Path $Path
    }
}

$resolvedTelerikPath = Resolve-Path -LiteralPath $TelerikPath

Add-Type -AssemblyName PresentationCore
Add-AssemblyIfPresent (Join-Path $resolvedTelerikPath "Telerik.Windows.Controls.dll")
Add-AssemblyIfPresent (Join-Path $resolvedTelerikPath "Telerik.Windows.Controls.Input.dll")
Add-AssemblyIfPresent (Join-Path $resolvedTelerikPath "Telerik.Windows.Themes.Fluent.dll")

$colorVariation = [Telerik.Windows.Controls.FluentPalette+ColorVariation]::$Variation
[Telerik.Windows.Controls.FluentPalette]::LoadPreset($colorVariation)
$palette = [Telerik.Windows.Controls.FluentPalette]::Palette

"FluentPalette $Variation preset"
"==============================="
$paletteProperties = @(
    "AccentColor",
    "AccentMouseOverColor",
    "AccentPressedColor",
    "AccentFocusedColor",
    "BasicColor",
    "BasicSolidColor",
    "IconColor",
    "MainColor",
    "MarkerColor",
    "MarkerMouseOverColor",
    "ValidationColor",
    "ComplementaryColor",
    "MouseOverColor",
    "PressedColor",
    "AlternativeColor",
    "MarkerInvertedColor",
    "PrimaryColor",
    "PrimaryBackgroundColor",
    "PrimaryMouseOverColor",
    "ReadOnlyBackgroundColor",
    "ReadOnlyBorderColor",
    "DisabledOpacity",
    "InputOpacity",
    "ReadOnlyOpacity"
)

foreach ($propertyName in $paletteProperties) {
    "{0,-30} {1}" -f $propertyName, $palette.$propertyName
}

""
"ThemeHelper dependency properties"
"================================="
[Telerik.Windows.Controls.Theming.Helpers.ThemeHelper].GetFields(
    [System.Reflection.BindingFlags]"Public,Static") |
    Where-Object { $_.FieldType -eq [System.Windows.DependencyProperty] } |
    Select-Object -ExpandProperty Name |
    Sort-Object
