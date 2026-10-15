<#
.SYNOPSIS
Initializes Mossbauer resources in the renderer's bare WPF Application.

.DESCRIPTION
Use from a trusted fixture running under Render-WpfFixture.ps1, in a fresh
PowerShell 7 STA process. Requires an existing application build. No build,
restore, product App construction, Prism shell, hardware, or network access.
The resource order and converters mirror Mossbauer\App.xaml; keep this local
bootstrap aligned with that file when application resources change.

Checks required assets before loading. Refuses non-bare applications, duplicate
initialization, and conflicting application converter resources. Produces no
pipeline output; metadata is available as Application.Resources['MossbauerFixtureBootstrap'].

.EXAMPLE
& "$PSScriptRoot\Initialize-MossbauerFixture.ps1" -AssemblyDirectory $AssemblyDirectory -Application $Application -Theme Dark

.EXAMPLE
pwsh -NoProfile -STA -File "$HOME\.copilot\tools\Mossbauer\Initialize-MossbauerFixture.ps1" -SelfTest -AssemblyDirectory "D:\repos\Mossbauer\Mossbauer\bin\Debug\net8.0-windows"
#>
param(
    [string]$AssemblyDirectory,
    [object]$Application,
    [ValidateSet('Light', 'Dark')][string]$Theme = 'Light',
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
if (-not $IsWindows -or $PSVersionTable.PSVersion.Major -lt 7 -or
    [System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    throw 'Requires a fresh Windows PowerShell 7 STA process.'
}
if (!$AssemblyDirectory -or !(Test-Path -LiteralPath $AssemblyDirectory -PathType Container)) {
    throw 'AssemblyDirectory must name an existing application build directory.'
}
$resolvedAssemblies = (Resolve-Path -LiteralPath $AssemblyDirectory).ProviderPath

if ($SelfTest) {
    if ($PSBoundParameters.Count -ne 2) { throw 'Use -SelfTest with -AssemblyDirectory only.' }
    $renderer = Join-Path (Split-Path $PSScriptRoot -Parent) 'Render-WpfFixture.ps1'
    if (!(Test-Path -LiteralPath $renderer -PathType Leaf)) { throw "Missing renderer: $renderer" }
    $directory = Join-Path ([System.IO.Path]::GetTempPath()) ('MossbauerFixture-' + [guid]::NewGuid().ToString('N'))
    [void][System.IO.Directory]::CreateDirectory($directory)
    $probe = Join-Path $directory 'Bootstrap.ps1'
    $light = Join-Path $directory 'Light.png'
    $dark = Join-Path $directory 'Dark.png'
    $failure = Join-Path $directory 'Failure.png'
    try {
        $source = @'
param($AssemblyDirectory, $Application, $Width, $Height, $Theme, $ProbeDirectory, [switch]$BadApplication)
$targetApplication = if ($BadApplication) { 'not a WPF Application' } else { $Application }
& '__BOOTSTRAP__' -AssemblyDirectory $ProbeDirectory -Application $targetApplication -Theme $Theme
$root = [System.Windows.Controls.TextBox]::new()
$root.Style = $Application.FindResource('MossbauerTextBoxStyle')
$root.Text = 'Bootstrap'
$root.Tag = $Theme
@{
    Root = $root
    AssertLayout = {
        param($Root, $Width, $Height)
        foreach ($key in @('MossbauerAccentBrush', 'MossbauerComboBoxStyle', 'MossbauerUnitsEntryResources', 'NullToVisibilityConverter')) {
            if (!$Root.FindResource($key)) { throw "Missing bootstrap resource: $key" }
        }
        if ([Mossbauer.Themes.MossbauerPalette]::CurrentTheme.ToString() -ne $Root.Tag) { throw 'Wrong theme.' }
        if ($Root.MinHeight -ne 32) { throw 'Wrong input style.' }
    }
}
'@
        [System.IO.File]::WriteAllText($probe, $source.Replace('__BOOTSTRAP__', $PSCommandPath.Replace("'", "''")))
        function Invoke-Probe($ProbeTheme, $ProbeDirectory, $Destination, $ExpectedError, [switch]$BadApplication) {
            $options = "@{ Theme = '$ProbeTheme'; ProbeDirectory = '$($ProbeDirectory.Replace("'", "''"))'"
            if ($BadApplication) { $options += '; BadApplication = $true' }
            $options += ' }'
            $command = "& '$($renderer.Replace("'", "''"))' -FixturePath '$($probe.Replace("'", "''"))' " +
                "-AssemblyDirectory '$($resolvedAssemblies.Replace("'", "''"))' -Width 220 -Height 60 " +
                "-OutputPath '$($Destination.Replace("'", "''"))' -FixtureParameters $options"
            $PSNativeCommandUseErrorActionPreference = $false
            $result = & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -STA -Command $command 2>&1
            if ($ExpectedError) {
                if ($LASTEXITCODE -eq 0 -or ($result -join "`n") -notmatch $ExpectedError) {
                    throw "Expected refusal '$ExpectedError'. Output: $($result -join "`n")"
                }
            } elseif ($LASTEXITCODE -ne 0) {
                throw "Bootstrap smoke render failed: $($result -join "`n")"
            }
        }
        Invoke-Probe Light $resolvedAssemblies $light
        Invoke-Probe Dark $resolvedAssemblies $dark
        Invoke-Probe Light $directory $failure 'Missing required build asset'
        Invoke-Probe Light $resolvedAssemblies $failure 'bare WPF Application' -BadApplication
        Invoke-Probe Unknown $resolvedAssemblies $failure 'Theme'
        if (Test-Path -LiteralPath $failure) { throw 'Failed bootstrap left an output image.' }
        'Self-test passed: light/dark resources, input styles, missing assets, application refusal, theme refusal, and cleanup.'
    } finally {
        foreach ($path in @($probe, $light, $dark, $failure)) {
            if ([System.IO.File]::Exists($path)) { [System.IO.File]::Delete($path) }
        }
        [System.IO.Directory]::Delete($directory)
    }
    return
}

$required = @(
    'Mossbauer.dll', 'WpfControls.dll', 'MLInfrastructure.dll',
    'Telerik.Windows.Themes.Fluent.dll', 'Telerik.Windows.Themes.Windows8.dll',
    'Telerik.Windows.Controls.dll', 'Telerik.Windows.Controls.Input.dll',
    'Telerik.Windows.Controls.Navigation.dll', 'Telerik.Windows.Controls.ImageEditor.dll',
    'Telerik.Windows.Controls.RibbonView.dll', 'Telerik.Windows.Controls.RichTextBox.dll',
    'Telerik.Windows.Controls.Data.dll', 'Telerik.Windows.Controls.GridView.dll', 'Telerik.Windows.Data.dll'
)
foreach ($name in $required) {
    if (!(Test-Path -LiteralPath (Join-Path $resolvedAssemblies $name) -PathType Leaf)) {
        throw "Missing required build asset: $name. Use an existing Mossbauer application build, not a test output directory."
    }
}
Add-Type -AssemblyName PresentationFramework, PresentationCore
if ($Application -isnot [System.Windows.Application] -or
    $Application.GetType() -ne [System.Windows.Application] -or
    ![object]::ReferenceEquals($Application, [System.Windows.Application]::Current) -or
    !$Application.Dispatcher.CheckAccess()) {
    throw 'Application must be the current bare WPF Application on its owning thread.'
}
$bootstrapKey = 'MossbauerFixtureBootstrap'
foreach ($key in @($bootstrapKey, 'BooleanToGridLengthConverter', 'NullToVisibilityConverter', 'NoDepletionToVisibilityConverter')) {
    if ($Application.Resources.Contains($key)) { throw "Bootstrap resource already exists: $key" }
}
foreach ($name in $required) {
    [void][System.Reflection.Assembly]::LoadFrom((Join-Path $resolvedAssemblies $name))
}
$Application.Resources.Add('BooleanToGridLengthConverter', [Mossbauer.Converters.BooleanToGridLengthConverter]::new())
$Application.Resources.Add('NullToVisibilityConverter', [Mossbauer.Converters.NullToVisibilityConverter]::new())
$Application.Resources.Add('NoDepletionToVisibilityConverter', [Mossbauer.Converters.NoDepletionToVisibilityConverter]::new())
foreach ($name in @('System.Windows', 'Telerik.Windows.Controls', 'Telerik.Windows.Controls.ImageEditor',
    'Telerik.Windows.Controls.Input', 'Telerik.Windows.Controls.Navigation', 'Telerik.Windows.Controls.RibbonView',
    'Telerik.Windows.Controls.RichTextBox', 'Telerik.Windows.Controls.Data', 'Telerik.Windows.Controls.GridView')) {
    $dictionary = [System.Windows.ResourceDictionary]::new()
    $dictionary.set_Source([Uri]::new("/Telerik.Windows.Themes.Fluent;component/Themes/$name.xaml", [UriKind]::Relative))
    $Application.Resources.MergedDictionaries.Add($dictionary)
}
foreach ($name in @('MossbauerLayoutTokens', 'MossbauerIcons', 'MossbauerTelerikControls',
    'MossbauerShellPrimitives', 'MossbauerDisplayPrimitives')) {
    $dictionary = [System.Windows.ResourceDictionary]::new()
    $dictionary.set_Source([Uri]::new("/Mossbauer;component/Themes/$name.xaml", [UriKind]::Relative))
    $Application.Resources.MergedDictionaries.Add($dictionary)
}
$selectedTheme = [Mossbauer.Themes.MossbauerTheme]::$Theme
[Mossbauer.Themes.MossbauerPalette]::ApplyTheme($selectedTheme)
$Application.Resources.Add($bootstrapKey, @{
    Theme = $Theme
    AssemblyDirectory = $resolvedAssemblies
    BuildModifiedUtc = (Get-Item -LiteralPath (Join-Path $resolvedAssemblies 'Mossbauer.dll')).LastWriteTimeUtc
})
