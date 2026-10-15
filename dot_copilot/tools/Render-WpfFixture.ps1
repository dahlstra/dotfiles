<#
.SYNOPSIS
Renders a trusted WPF fixture in a hidden native host.

.DESCRIPTION
Run in a fresh Windows PowerShell 7 process with -STA. Requires an existing
build; does not build, install dependencies, or start the target application.

The fixture is a .ps1 script accepting AssemblyDirectory, Application, Width,
and Height parameters. It must return exactly one hashtable with a Root
FrameworkElement and, optionally, an AssertLayout scriptblock. Load application
assemblies and resource dictionaries explicitly in the fixture. Application is
a bare WPF Application, not the product's App class.

The native host supplies an AdornerDecorator so field validation chrome can
render. FixtureParameters passes explicit additional parameters declared by the
fixture, such as Theme or State. It cannot override the four host parameters.
The fixture may return an Evidence hashtable describing its scenario and source.
Outputs include fixture/build paths, explicit options, and this evidence.

AssertLayout receives Root, Width, and Height after Loaded, binding processing,
and layout. It must inspect without changing the UI, throw on failure, and
produce no pipeline output. Use [void] for methods that return values.
WPF-reported binding errors fail the render; assertions must also verify
critical data and resource values, since not every missing value is an error.

Fixtures are executable code, not sandboxed. Use only trusted local fixtures
without hardware access, application startup, or destructive side effects.
One invocation renders one fixture at one size/state/theme. Use separate
processes for other cases, keeping product-specific setup out of this tool.

Width and Height are DIPs. PNG pixel dimensions and DPI follow the hidden
host's current Windows DPI. Output reports both logical and pixel dimensions.
Success establishes only the fixture's layout assertions and binding results,
not full-app commands, accessibility, keyboard behavior, or hardware behavior.

OutputPath must be a new .png in an existing directory. Existing files are
never overwritten. Missing inputs, unresolved dependencies, required static
resource lookup failures, invalid fixtures, binding errors, assertion failures,
and oversized renders fail explicitly.

With -CaptureOnFailure, failures after a native visual is available save
diagnostic siblings of OutputPath: <name>.failure.png and <name>.failure.json.
The JSON is explicitly marked Failed and includes the original error, binding
diagnostics, fixture options, and native dimensions/DPI. These artifacts are not
passing evidence: OutputPath is not written and the command still fails.
Existing diagnostic files are never overwritten. Failures before the native
visual exists produce no diagnostic screenshot.

.EXAMPLE
pwsh -NoProfile -STA -File "$HOME\.copilot\tools\Render-WpfFixture.ps1" `
    -FixturePath ".\StatusFixture.ps1" `
    -AssemblyDirectory ".\Mossbauer\bin\Debug\net8.0-windows" `
    -Width 800 -Height 600 -OutputPath "$env:TEMP\status-dark.png"

.EXAMPLE
pwsh -NoProfile -STA -File "$HOME\.copilot\tools\Render-WpfFixture.ps1" -SelfTest

.EXAMPLE
pwsh -NoProfile -STA -Command '& "$HOME\.copilot\tools\Render-WpfFixture.ps1" -FixturePath "$HOME\.copilot\tools\Mossbauer\EntryControls.fixture.ps1" -AssemblyDirectory "D:\repos\Mossbauer\Mossbauer\bin\Debug\net8.0-windows" -Width 300 -Height 540 -OutputPath "$env:TEMP\entries-dark.png" -FixtureParameters @{ Theme = "Dark"; State = "All" }'

.EXAMPLE
pwsh -NoProfile -STA -File "$HOME\.copilot\tools\Render-WpfFixture.ps1" -FixturePath ".\StatusFixture.ps1" -AssemblyDirectory ".\Mossbauer\bin\Debug\net8.0-windows" -Width 300 -Height 540 -OutputPath "$env:TEMP\status.png" -CaptureOnFailure

.PARAMETER CaptureOnFailure
Save diagnostic .failure.png and .failure.json siblings when a native visual is
available after a failure. The original error is still thrown; no passing output
or successful exit status is produced. Existing diagnostic files are refused.

.NOTES
Minimal fixture:
    param($AssemblyDirectory, $Application, $Width, $Height)
    $root = [System.Windows.Controls.TextBlock]::new()
    $root.Text = 'Fixture'
    @{
        Root = $root
        AssertLayout = {
            param($Root, $Width, $Height)
            if ($Root.ActualWidth -le 0) { throw 'Root has no width.' }
        }
    }

For ResourceDictionary in PowerShell, use set_Source([Uri]...) to load a
dictionary. Assigning .Source can instead create an IDictionary entry.
Output images are evidence to inspect, not automatic visual approval.
#>
param(
    [string]$FixturePath,
    [string]$AssemblyDirectory,
    [double]$Width,
    [double]$Height,
    [string]$OutputPath,
    [hashtable]$FixtureParameters = @{},
    [switch]$CaptureOnFailure,
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

if (-not $IsWindows -or $PSVersionTable.PSVersion.Major -lt 7) {
    throw "Requires PowerShell 7 on Windows."
}
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne "STA") {
    throw "Run in a fresh STA process: pwsh -NoProfile -STA -File `"$PSCommandPath`" ..."
}

function Assert-RenderDimensions {
    param([double]$RenderWidth, [double]$RenderHeight)

    if (-not [double]::IsFinite($RenderWidth) -or -not [double]::IsFinite($RenderHeight) -or
        $RenderWidth -le 0 -or $RenderHeight -le 0 -or
        $RenderWidth -gt 16384 -or $RenderHeight -gt 16384 -or
        $RenderWidth * $RenderHeight -gt 64000000) {
        throw "Render dimensions must be finite and positive, at most 16384 per axis and 64 million total."
    }
}

function Save-PngImage {
    param($Bitmap, [string]$Destination)

    $encoder = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($Bitmap))
    $stream = [System.IO.File]::Open(
        $Destination, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    $saved = $false
    try {
        $encoder.Save($stream)
        $stream.Dispose()
        $saved = $true
    } finally {
        $stream.Dispose()
        if (!$saved) { [System.IO.File]::Delete($Destination) }
    }
}

if ($SelfTest) {
    if ($PSBoundParameters.Count -ne 1) {
        throw "Use -SelfTest without render parameters."
    }
    $testDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("WpfFixture-" + [guid]::NewGuid().ToString("N"))
    [void][System.IO.Directory]::CreateDirectory($testDirectory)
    $validFixture = Join-Path $testDirectory "Valid.ps1"
    $bindingFixture = Join-Path $testDirectory "BindingError.ps1"
    $invalidFixture = Join-Path $testDirectory "Invalid.ps1"
    $assertionFixture = Join-Path $testDirectory "AssertionError.ps1"
    $resourceFixture = Join-Path $testDirectory "MissingResource.ps1"
    $assemblyFixture = Join-Path $testDirectory "MissingAssembly.ps1"
    $adornerFixture = Join-Path $testDirectory "Adorner.ps1"
    $optionFixture = Join-Path $testDirectory "Options.ps1"
    $parseFixture = Join-Path $testDirectory "ParseError.ps1"
    $combinedFixture = Join-Path $testDirectory "BindingAndAssertionError.ps1"
    $capturedAssertion = Join-Path $testDirectory "CapturedAssertion.png"
    $capturedBinding = Join-Path $testDirectory "CapturedBinding.png"
    $capturedCombined = Join-Path $testDirectory "CapturedCombined.png"
    $capturedSuccess = Join-Path $testDirectory "CapturedSuccess.png"
    $imagePath = Join-Path $testDirectory "Valid.png"
    $adornerImage = Join-Path $testDirectory "Adorner.png"
    $optionImage = Join-Path $testDirectory "Options.png"
    $failurePath = Join-Path $testDirectory "Failure.png"
    try {
        [System.IO.File]::WriteAllText($validFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
$dictionary = [System.Windows.ResourceDictionary]::new()
$dictionary.Add('FixtureBrush', [System.Windows.Media.Brushes]::DarkRed)
$Application.Resources.MergedDictionaries.Add($dictionary)
$root = [System.Windows.Controls.Border]::new()
$root.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, 'FixtureBrush')
$text = [System.Windows.Controls.TextBlock]::new()
$text.DataContext = [pscustomobject]@{ Label = 'Fixture' }
[void]$text.SetBinding([System.Windows.Controls.TextBlock]::TextProperty, [System.Windows.Data.Binding]::new('Label'))
$root.Child = $text
@{
    Root = $root
    AssertLayout = {
        param($Root, $Width, $Height)
        if (!$Root.IsLoaded) { throw 'Loaded lifecycle did not run.' }
        if ([Math]::Abs($Root.ActualWidth - $Width) -gt 0.01 -or
            [Math]::Abs($Root.ActualHeight - $Height) -gt 0.01) { throw 'Logical size mismatch.' }
        if ($Root.Child.Text -ne 'Fixture') { throw 'Binding was not processed.' }
    }
}
'@)
        [System.IO.File]::WriteAllText($bindingFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
$root = [System.Windows.Controls.TextBlock]::new()
$root.DataContext = [System.Windows.Point]::new(1, 2)
[void]$root.SetBinding([System.Windows.Controls.TextBlock]::TextProperty, [System.Windows.Data.Binding]::new('Missing'))
@{ Root = $root }
'@)
        [System.IO.File]::WriteAllText($invalidFixture, "param(`$AssemblyDirectory, `$Application, `$Width, `$Height)`n@{ Root = 'not a visual' }")
        [System.IO.File]::WriteAllText($assertionFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
@{
    Root = [System.Windows.Controls.Border]::new()
    AssertLayout = { param($Root, $Width, $Height); throw 'Deliberate assertion failure.' }
}
'@)
        [System.IO.File]::WriteAllText($resourceFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
$root = [System.Windows.Markup.XamlReader]::Parse('<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Background="{StaticResource MissingFixtureBrush}" />')
@{ Root = $root }
'@)
        [System.IO.File]::WriteAllText($assemblyFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
[void][System.Reflection.Assembly]::Load('WpfFixture.DeliberatelyMissing')
@{ Root = [System.Windows.Controls.Border]::new() }
'@)
        [System.IO.File]::WriteAllText($adornerFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
$root = [System.Windows.Controls.TextBox]::new()
$binding = [System.Windows.Data.Binding]::new('X')
$binding.Source = [System.Windows.Point]::new(1, 2)
$expression = $root.SetBinding([System.Windows.Controls.TextBox]::TextProperty, $binding)
$error = [System.Windows.Controls.ValidationError]::new(
    [System.Windows.Controls.ExceptionValidationRule]::new(), $expression, 'Invalid fixture value', $null)
[System.Windows.Controls.Validation]::MarkInvalid($expression, $error)
@{
    Root = $root
    AssertLayout = {
        param($Root, $Width, $Height)
        $layer = [System.Windows.Documents.AdornerLayer]::GetAdornerLayer($Root)
        if (!$layer -or ![System.Windows.Controls.Validation]::GetHasError($Root) -or
            !$layer.GetAdorners($Root)) { throw 'Validation adorner was not hosted.' }
    }
}
'@)
        [System.IO.File]::WriteAllText($optionFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height, [ValidateSet('Dark')]$Theme)
$root = [System.Windows.Controls.TextBlock]::new()
$root.Text = $Theme
@{
    Root = $root
    Evidence = @{ Scenario = 'Options'; Theme = $Theme }
    AssertLayout = {
        param($Root, $Width, $Height)
        if ($Root.Text -ne 'Dark') { throw 'Fixture parameter was not passed.' }
    }
}
'@)
        [System.IO.File]::WriteAllText($parseFixture, 'param(')
        [System.IO.File]::WriteAllText($combinedFixture, @'
param($AssemblyDirectory, $Application, $Width, $Height)
$root = [System.Windows.Controls.TextBlock]::new()
$root.DataContext = [System.Windows.Point]::new(1, 2)
[void]$root.SetBinding([System.Windows.Controls.TextBlock]::TextProperty, [System.Windows.Data.Binding]::new('Missing'))
@{
    Root = $root
    AssertLayout = { param($Root, $Width, $Height); throw 'Deliberate assertion failure with binding error.' }
}
'@)

        function Invoke-TestRender {
            param([string]$Fixture, [double]$TestWidth, [string]$Destination,
                [string]$ExpectedError, [string]$Options = '@{}', [switch]$CaptureOnFailure)

            $PSNativeCommandUseErrorActionPreference = $false
            $command = "& '$($PSCommandPath.Replace("'", "''"))' " +
                "-FixturePath '$($Fixture.Replace("'", "''"))' " +
                "-AssemblyDirectory '$($testDirectory.Replace("'", "''"))' " +
                "-Width $($TestWidth.ToString([System.Globalization.CultureInfo]::InvariantCulture)) " +
                "-Height 60 -OutputPath '$($Destination.Replace("'", "''"))' -FixtureParameters $Options "
            if ($CaptureOnFailure) { $command += "-CaptureOnFailure " }
            $command += "| ConvertTo-Json -Depth 5 -Compress"
            $result = & (Join-Path $PSHOME "pwsh.exe") -NoProfile -STA -Command $command 2>&1
            if ($ExpectedError) {
                if ($LASTEXITCODE -eq 0 -or ($result -join "`n") -notmatch $ExpectedError) {
                    throw "Expected refusal '$ExpectedError'. Output: $($result -join "`n")"
                }
            } elseif ($LASTEXITCODE -ne 0) {
                throw "Render failed: $($result -join "`n")"
            } else {
                $report = ($result -join "`n") | ConvertFrom-Json
                if ($report.OutputPath -ne $Destination -or $report.BindingErrorCount -ne 0) {
                    throw "Invalid render evidence: $($result -join "`n")"
                }
                if ($Fixture -eq $optionFixture -and
                    ($report.FixtureParameters.Theme -ne 'Dark' -or $report.Evidence.Theme -ne 'Dark')) {
                    throw "Explicit fixture options or evidence were not reported."
                }
            }
        }

        Invoke-TestRender $validFixture 80 $imagePath
        Add-Type -AssemblyName PresentationFramework, PresentationCore
        $stream = [System.IO.File]::OpenRead($imagePath)
        try {
            $decoder = [System.Windows.Media.Imaging.PngBitmapDecoder]::new(
                $stream, [System.Windows.Media.Imaging.BitmapCreateOptions]::None,
                [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
            $frame = $decoder.Frames[0]
            if ([Math]::Abs($frame.PixelWidth - 80 * $frame.DpiX / 96) -gt 1 -or
                [Math]::Abs($frame.PixelHeight - 60 * $frame.DpiY / 96) -gt 1) {
                throw "PNG dimensions do not match logical size and encoded DPI."
            }
            $pixel = [byte[]]::new(4)
            $converted = [System.Windows.Media.Imaging.FormatConvertedBitmap]::new(
                $frame, [System.Windows.Media.PixelFormats]::Bgra32, $null, 0)
            $converted.CopyPixels([System.Windows.Int32Rect]::new(
                $frame.PixelWidth - 1, $frame.PixelHeight - 1, 1, 1), $pixel, 4, 0)
            if ($pixel[2] -ne 139 -or $pixel[3] -ne 255) {
                throw "Image is clipped or fixture background did not render."
            }
        } finally {
            $stream.Dispose()
        }
        $originalHash = (Get-FileHash -LiteralPath $imagePath).Hash
        Invoke-TestRender $validFixture 80 $imagePath "already exists"
        if ((Get-FileHash -LiteralPath $imagePath).Hash -ne $originalHash) {
            throw "Existing image changed during overwrite refusal."
        }
        foreach ($invalidWidth in @(0, -1, [double]::NaN, [double]::PositiveInfinity, 17000)) {
            Invoke-TestRender $validFixture $invalidWidth $failurePath "dimensions"
        }
        Invoke-TestRender $bindingFixture 80 $failurePath "WPF binding errors"
        Invoke-TestRender $invalidFixture 80 $failurePath "FrameworkElement"
        Invoke-TestRender $assertionFixture 80 $failurePath "Deliberate assertion failure"
        Invoke-TestRender $resourceFixture 80 $failurePath "StaticResourceExtension"
        Invoke-TestRender $assemblyFixture 80 $failurePath "WpfFixture.DeliberatelyMissing"
        Invoke-TestRender (Join-Path $testDirectory "Missing.ps1") 80 $failurePath "FixturePath"
        Invoke-TestRender $adornerFixture 80 $adornerImage
        Invoke-TestRender $optionFixture 80 $optionImage -Options "@{ Theme = 'Dark' }"
        Invoke-TestRender $optionFixture 80 $failurePath "not declared" "@{ Theem = 'Dark' }"
        Invoke-TestRender $optionFixture 80 $failurePath "host parameter" "@{ Width = 1 }"
        Invoke-TestRender $optionFixture 80 $failurePath "parameter name" "@{ 'Bad-Name' = 1 }"
        Invoke-TestRender $optionFixture 80 $failurePath "cannot be null" '$null'
        Invoke-TestRender $parseFixture 80 $failurePath "parse errors"
        if (Test-Path -LiteralPath $failurePath) {
            throw "Failed render left an output image."
        }
        Invoke-TestRender $validFixture 80 $capturedSuccess -CaptureOnFailure
        foreach ($extension in @('failure.png', 'failure.json')) {
            if (Test-Path -LiteralPath ([System.IO.Path]::ChangeExtension($capturedSuccess, $extension))) {
                throw 'Passing render produced failure diagnostics.'
            }
        }
        foreach ($case in @(
            @{ Fixture = $assertionFixture; Output = $capturedAssertion; Error = 'Deliberate assertion failure'; Binding = $false },
            @{ Fixture = $bindingFixture; Output = $capturedBinding; Error = 'WPF binding errors'; Binding = $true },
            @{ Fixture = $combinedFixture; Output = $capturedCombined; Error = 'Deliberate assertion failure with binding error'; Binding = $true }
        )) {
            Invoke-TestRender $case.Fixture 80 $case.Output $case.Error -CaptureOnFailure
            $diagnosticImage = [System.IO.Path]::ChangeExtension($case.Output, 'failure.png')
            $diagnosticReport = [System.IO.Path]::ChangeExtension($case.Output, 'failure.json')
            if ((Test-Path -LiteralPath $case.Output) -or
                !(Test-Path -LiteralPath $diagnosticImage) -or !(Test-Path -LiteralPath $diagnosticReport)) {
                throw 'Failure capture must produce only diagnostic image/report paths.'
            }
            $report = Get-Content -LiteralPath $diagnosticReport -Raw | ConvertFrom-Json
            if ($report.Status -ne 'Failed' -or !$report.DiagnosticOnly -or
                $report.Failure -notmatch $case.Error -or
                [bool]$report.BindingErrors -ne $case.Binding -or $report.DpiX -le 0 -or
                $report.OutputPath -ne $diagnosticImage) {
                throw 'Failure diagnostic report is incomplete or success-shaped.'
            }
            $imageHash = (Get-FileHash -LiteralPath $diagnosticImage).Hash
            $reportHash = (Get-FileHash -LiteralPath $diagnosticReport).Hash
            Invoke-TestRender $case.Fixture 80 $case.Output 'already exists' -CaptureOnFailure
            if ((Get-FileHash -LiteralPath $diagnosticImage).Hash -ne $imageHash -or
                (Get-FileHash -LiteralPath $diagnosticReport).Hash -ne $reportHash) {
                throw 'Existing failure diagnostics changed during overwrite refusal.'
            }
            [System.IO.File]::Delete($diagnosticImage)
            Invoke-TestRender $case.Fixture 80 $case.Output 'already exists' -CaptureOnFailure
            if ((Test-Path -LiteralPath $diagnosticImage) -or
                (Get-FileHash -LiteralPath $diagnosticReport).Hash -ne $reportHash) {
                throw 'Existing report must be refused before writing a diagnostic image.'
            }
        }
        "Self-test passed: native lifecycle, layout, binding, adorners, explicit options, DPI, rendered pixels, failure capture, overwrite refusal, failure cases, and cleanup."
    } finally {
        foreach ($path in @($validFixture, $bindingFixture, $invalidFixture, $assertionFixture,
            $resourceFixture, $assemblyFixture, $adornerFixture, $optionFixture, $parseFixture,
            $imagePath, $adornerImage, $optionImage, $failurePath, $combinedFixture, $capturedSuccess)) {
            if ([System.IO.File]::Exists($path)) { [System.IO.File]::Delete($path) }
        }
        foreach ($path in @($capturedAssertion, $capturedBinding, $capturedCombined, $capturedSuccess)) {
            foreach ($extension in @('failure.png', 'failure.json')) {
                $diagnosticPath = [System.IO.Path]::ChangeExtension($path, $extension)
                if ([System.IO.File]::Exists($diagnosticPath)) { [System.IO.File]::Delete($diagnosticPath) }
            }
        }
        [System.IO.Directory]::Delete($testDirectory)
    }
    return
}

Assert-RenderDimensions $Width $Height
if (-not $FixturePath -or -not (Test-Path -LiteralPath $FixturePath -PathType Leaf) -or
    [System.IO.Path]::GetExtension($FixturePath) -ne ".ps1") {
    throw "FixturePath must name an existing .ps1 file."
}
if (-not $AssemblyDirectory -or -not (Test-Path -LiteralPath $AssemblyDirectory -PathType Container)) {
    throw "AssemblyDirectory must name an existing build directory."
}
if (-not $OutputPath -or [System.IO.Path]::GetExtension($OutputPath) -ne ".png") {
    throw "OutputPath must name a new .png file."
}
$resolvedFixture = (Resolve-Path -LiteralPath $FixturePath).ProviderPath
$resolvedAssemblies = (Resolve-Path -LiteralPath $AssemblyDirectory).ProviderPath
if ($null -eq $FixtureParameters) {
    throw "FixtureParameters cannot be null."
}
$parseErrors = $null
$tokens = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($resolvedFixture, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count -gt 0) {
    throw "Fixture contains parse errors: $($parseErrors.Message -join '; ')"
}
$declaredParameters = @($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
$invokeParameters = @{
    AssemblyDirectory = $resolvedAssemblies
    Application = $null
    Width = $Width
    Height = $Height
}
foreach ($key in $invokeParameters.Keys) {
    if ($declaredParameters -notcontains $key) {
        throw "Fixture must declare host parameter '$key'."
    }
}
foreach ($key in $FixtureParameters.Keys) {
    if ($key -isnot [string] -or $key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
        throw "Invalid fixture parameter name: $key"
    }
    if ($invokeParameters.ContainsKey($key)) {
        throw "FixtureParameters cannot override host parameter '$key'."
    }
    if ($declaredParameters -notcontains $key) {
        throw "Fixture parameter '$key' is not declared by the fixture."
    }
    $invokeParameters.Add($key, $FixtureParameters[$key])
}
$resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (Test-Path -LiteralPath $resolvedOutput) {
    throw "OutputPath already exists; refusing to overwrite: $resolvedOutput"
}
if (-not [System.IO.Directory]::Exists([System.IO.Path]::GetDirectoryName($resolvedOutput))) {
    throw "OutputPath parent directory must already exist."
}
$failureImage = [System.IO.Path]::ChangeExtension($resolvedOutput, 'failure.png')
$failureReport = [System.IO.Path]::ChangeExtension($resolvedOutput, 'failure.json')
if ($CaptureOnFailure) {
    foreach ($path in @($failureImage, $failureReport)) {
        if (Test-Path -LiteralPath $path) { throw "Diagnostic output already exists; refusing to overwrite: $path" }
    }
}

Add-Type -AssemblyName PresentationFramework, PresentationCore
if ([System.Windows.Application]::Current) {
    throw "A WPF Application already exists. Use a fresh PowerShell process."
}
$application = [System.Windows.Application]::new()
$invokeParameters.Application = $application
$application.ShutdownMode = [System.Windows.ShutdownMode]::OnExplicitShutdown
$resolver = [System.ResolveEventHandler]({
    param($Sender, $EventArgs)
    $name = ([System.Reflection.AssemblyName]::new($EventArgs.Name)).Name + ".dll"
    if ([System.IO.Path]::GetFileName($name) -ne $name) {
        throw "Invalid requested assembly name: $name"
    }
    $path = Join-Path $resolvedAssemblies $name
    if ([System.IO.File]::Exists($path)) {
        return [System.Reflection.Assembly]::LoadFrom($path)
    }
    return $null
}.GetNewClosure())
[System.Diagnostics.PresentationTraceSources]::Refresh()
$bindingSource = [System.Diagnostics.PresentationTraceSources]::DataBindingSource
$originalTraceLevel = $bindingSource.Switch.Level
$bindingErrors = [System.IO.StringWriter]::new()
$listener = [System.Diagnostics.TextWriterTraceListener]::new($bindingErrors)
$hostSource = $null
try {
    [AppDomain]::CurrentDomain.add_AssemblyResolve($resolver)
    [void]$bindingSource.Listeners.Add($listener)
    $bindingSource.Switch.Level = [System.Diagnostics.SourceLevels]::Error
    $fixtureResults = @(& $resolvedFixture @invokeParameters)
    if ($fixtureResults.Count -ne 1 -or $fixtureResults[0] -isnot [hashtable] -or
        $fixtureResults[0].Root -isnot [System.Windows.FrameworkElement]) {
        throw "Fixture must return exactly one hashtable with a Root FrameworkElement."
    }
    $fixture = $fixtureResults[0]
    if ($fixture.ContainsKey("AssertLayout") -and $fixture.AssertLayout -isnot [scriptblock]) {
        throw "Fixture AssertLayout must be a scriptblock."
    }
    if ($fixture.ContainsKey("Evidence") -and $fixture.Evidence -isnot [hashtable]) {
        throw "Fixture Evidence must be a hashtable."
    }
    if ($fixture.Root.Parent -or [System.Windows.PresentationSource]::FromVisual($fixture.Root)) {
        throw "Fixture Root must not already have a parent or native host."
    }

    $parameters = [System.Windows.Interop.HwndSourceParameters]::new("WPF fixture render")
    $parameters.WindowStyle = -2147483648
    $parameters.Width = 1
    $parameters.Height = 1
    $hostSource = [System.Windows.Interop.HwndSource]::new($parameters)
    $dpiX = 96 * $hostSource.CompositionTarget.TransformToDevice.M11
    $dpiY = 96 * $hostSource.CompositionTarget.TransformToDevice.M22
    $pixelWidth = [Math]::Ceiling($Width * $dpiX / 96)
    $pixelHeight = [Math]::Ceiling($Height * $dpiY / 96)
    Assert-RenderDimensions $pixelWidth $pixelHeight
    $hostSource.Dispose()
    $hostSource = $null
    $parameters.Width = [int]$pixelWidth
    $parameters.Height = [int]$pixelHeight
    $hostSource = [System.Windows.Interop.HwndSource]::new($parameters)
    if ([Math]::Abs(96 * $hostSource.CompositionTarget.TransformToDevice.M11 - $dpiX) -gt 0.01 -or
        [Math]::Abs(96 * $hostSource.CompositionTarget.TransformToDevice.M22 - $dpiY) -gt 0.01) {
        throw "Host DPI changed during setup; rerun the fixture."
    }
    $surface = [System.Windows.Controls.Grid]::new()
    $surface.Width = $Width
    $surface.Height = $Height
    $surface.ClipToBounds = $true
    $adornerDecorator = [System.Windows.Documents.AdornerDecorator]::new()
    $adornerDecorator.Child = $fixture.Root
    [void]$surface.Children.Add($adornerDecorator)
    $hostSource.RootVisual = $surface
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
        [Action]{}, [System.Windows.Threading.DispatcherPriority]::ContextIdle)
    $surface.Measure([System.Windows.Size]::new($Width, $Height))
    $surface.Arrange([System.Windows.Rect]::new(0, 0, $Width, $Height))
    $surface.UpdateLayout()
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
        [Action]{}, [System.Windows.Threading.DispatcherPriority]::ContextIdle)
    $surface.UpdateLayout()
    if ($fixture.ContainsKey("AssertLayout")) {
        $assertionOutput = @(& $fixture.AssertLayout $fixture.Root $Width $Height)
        if ($assertionOutput.Count -ne 0) {
            throw "AssertLayout must throw on failure and produce no pipeline output."
        }
    }
    $bitmap = [System.Windows.Media.Imaging.RenderTargetBitmap]::new(
        [int]$pixelWidth, [int]$pixelHeight, $dpiX, $dpiY,
        [System.Windows.Media.PixelFormats]::Pbgra32)
    $bitmap.Render($surface)
    $listener.Flush()
    if ($bindingErrors.ToString()) {
        throw "WPF binding errors:`n$($bindingErrors.ToString())"
    }
    Save-PngImage $bitmap $resolvedOutput
    [pscustomobject]@{
        OutputPath = $resolvedOutput
        FixturePath = $resolvedFixture
        AssemblyDirectory = $resolvedAssemblies
        FixtureParameters = $FixtureParameters
        Evidence = $fixture.Evidence
        Width = $Width
        Height = $Height
        PixelWidth = [int]$pixelWidth
        PixelHeight = [int]$pixelHeight
        DpiX = $dpiX
        DpiY = $dpiY
        LayoutAssertions = $fixture.ContainsKey("AssertLayout")
        BindingErrorCount = 0
    }
} catch {
    $renderFailure = $_
    if ($CaptureOnFailure -and $hostSource -and $hostSource.RootVisual) {
        try {
            $listener.Flush()
            $diagnosticBitmap = [System.Windows.Media.Imaging.RenderTargetBitmap]::new(
                [int]$pixelWidth, [int]$pixelHeight, $dpiX, $dpiY,
                [System.Windows.Media.PixelFormats]::Pbgra32)
            $diagnosticBitmap.Render($surface)
            Save-PngImage $diagnosticBitmap $failureImage
            $report = [ordered]@{
                Status = 'Failed'
                DiagnosticOnly = $true
                Failure = $renderFailure.ToString()
                ScriptStackTrace = $renderFailure.ScriptStackTrace
                BindingErrors = $bindingErrors.ToString()
                OutputPath = $failureImage
                FixturePath = $resolvedFixture
                AssemblyDirectory = $resolvedAssemblies
                FixtureParameters = $FixtureParameters
                Evidence = $fixture.Evidence
                Width = $Width
                Height = $Height
                PixelWidth = [int]$pixelWidth
                PixelHeight = [int]$pixelHeight
                DpiX = $dpiX
                DpiY = $dpiY
            } | ConvertTo-Json -Depth 8
            $reportStream = [System.IO.File]::Open(
                $failureReport, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
            $reportSaved = $false
            try {
                $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($report)
                $reportStream.Write($bytes, 0, $bytes.Length)
                $reportStream.Dispose()
                $reportSaved = $true
            } finally {
                $reportStream.Dispose()
                if (!$reportSaved) { [System.IO.File]::Delete($failureReport) }
            }
            Write-Warning "Render failed. Diagnostic-only artifacts: $failureImage; $failureReport"
        } catch {
            throw [System.AggregateException]::new(
                'Rendering failed and failure diagnostics could not be completed.',
                [System.Exception[]]@($renderFailure.Exception, $_.Exception))
        }
    }
    throw $renderFailure
} finally {
    if ($hostSource) {
        $hostSource.RootVisual = $null
        $hostSource.Dispose()
    }
    $bindingSource.Listeners.Remove($listener)
    $bindingSource.Switch.Level = $originalTraceLevel
    $listener.Dispose()
    $bindingErrors.Dispose()
    [AppDomain]::CurrentDomain.remove_AssemblyResolve($resolver)
    $application.Shutdown()
}
