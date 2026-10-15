<#
.SYNOPSIS
Standalone Mossbauer paired-card rendering and layout checks.

.DESCRIPTION
Use with Render-WpfFixture.ps1 and explicit FixtureParameters:
RepositoryRoot = the Mossbauer repository; Theme = Light or Dark;
State = Populated, Empty, or Running.
Uses current Instruments/Source/Installed source XAML snippets and the compiled
MeasurementProgressCard primitive, without constructing the shell, Prism regions,
charts, or hardware. Source markup and compiled resource dictionaries are distinct
inputs: rebuild when relevant compiled controls/styles change, under the task's
validation policy. This fixture does not validate full-page layout or commands.

Cards are constrained to at most 340 DIPs, with a 16-DIP outer inset. Narrow
content wraps; extra workspace width remains outside the cards. Source cards'
production parent widths/scrolling are not replaced or validated by this fixture.

.EXAMPLE
pwsh -NoProfile -STA -Command '& "$HOME\.copilot\tools\Render-WpfFixture.ps1" -FixturePath "$HOME\.copilot\tools\Mossbauer\PresentationCards.fixture.ps1" -AssemblyDirectory "D:\repos\Mossbauer\Mossbauer\bin\Debug\net8.0-windows" -Width 315 -Height 1500 -OutputPath "$env:TEMP\cards-dark.png" -FixtureParameters @{ RepositoryRoot = "D:\repos\Mossbauer"; Theme = "Dark"; State = "Running" }'

.NOTES
Repeatable smoke check: run in fresh processes at widths 315, 380, and 600,
height 1500, with new PNG paths under the OS temp directory. Cover both themes
and Empty/Running states. The renderer asserts geometry and refuses binding errors.
Inspect PNGs and returned evidence. Expected refusals: missing RepositoryRoot,
unknown Theme/State, width below 260 or height below 1100; use a fresh output path
and confirm no image was written. Delete only the images you created afterward.
No unit-test integration.
#>
param(
    $AssemblyDirectory, $Application, $Width, $Height,
    [string]$RepositoryRoot,
    [ValidateSet('Light', 'Dark')][string]$Theme = 'Light',
    [ValidateSet('Populated', 'Empty', 'Running')][string]$State = 'Populated'
)
$ErrorActionPreference = 'Stop'
if (!$RepositoryRoot -or !(Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    throw 'RepositoryRoot must name the Mossbauer repository.'
}
if ($Width -lt 260 -or $Height -lt 1100) { throw 'Card fixture requires at least 260 x 1100 DIPs; use height 1500 for long-content cases.' }
$resolvedRepository = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
$shellPath = Join-Path $resolvedRepository 'Mossbauer\Shell\MainWindow.xaml'
$sourcePath = Join-Path $resolvedRepository 'Mossbauer\SourceMonitor\SourceMonitorView.xaml'
foreach ($path in @($shellPath, $sourcePath)) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing source markup: $path" }
}
$shellDocument = [xml](Get-Content -LiteralPath $shellPath -Raw)
$sourceDocument = [xml](Get-Content -LiteralPath $sourcePath -Raw)
& "$PSScriptRoot\Initialize-MossbauerFixture.ps1" -AssemblyDirectory $AssemblyDirectory -Application $Application -Theme $Theme
$Application.Resources.Add('IsLastItemToBorderThicknessConverter', [LakeShore.Mossbauer.Instruments.IsLastItemToBorderThicknessConverter]::new())
$deviation = $sourceDocument.SelectSingleNode("//*[local-name()='Style' and @*[local-name()='Key']='DeviationValueText']")
if (!$deviation) { throw 'Expected source DeviationValueText style is missing.' }
$resources = [System.Windows.Markup.XamlReader]::Parse(
    '<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">' +
    $deviation.OuterXml + '</ResourceDictionary>')
$resources.Add('BooleanToCollapsedConverter', [LakeShore.MLInfrastructure.BooleanToCollapsedConverter]::new())
$Application.Resources.MergedDictionaries.Add($resources)

function Import-Card($Document, $Title) {
    $nodes = $Document.SelectNodes("//*[local-name()='Card' and @Title='$Title']")
    if ($nodes.Count -ne 1) { throw "Expected exactly one source card: $Title" }
    $markup = $nodes[0].OuterXml -replace 'clr-namespace:Mossbauer\.Display(?=["''])', 'clr-namespace:Mossbauer.Display;assembly=Mossbauer'
    $wrapper = '<Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:display="clr-namespace:Mossbauer.Display;assembly=Mossbauer" xmlns:telerik="http://schemas.telerik.com/2008/xaml/presentation">' + $markup + '</Grid>'
    $container = [System.Windows.Markup.XamlReader]::Parse($wrapper)
    $card = $container.Children[0]
    $container.Children.Remove($card)
    $card.Width = [double]::NaN
    $card.MaxWidth = 340
    $card.Margin = [System.Windows.Thickness]::new(0, 0, 0, 12)
    return $card
}
$root = [System.Windows.Controls.Border]::new()
$root.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, 'MossbauerContentBackgroundBrush')
$body = [System.Windows.Controls.StackPanel]::new()
$body.Width = [Math]::Min(340, $Width - 32)
$body.HorizontalAlignment = 'Left'
$body.Margin = [System.Windows.Thickness]::new(16)
$root.Child = $body
$populated = $State -ne 'Empty'
if ($State -eq 'Running') {
    $progress = [Mossbauer.Display.MeasurementProgressCard]::new()
    $progress.Title = 'Current measurement'
    $progress.MeasurementName = 'Temperature sequence - 100 K (1)'
    $progress.TypeLabel = 'Variable Temperature'
    $progress.PhaseText = 'Measurement stopped; finish operations in progress.'
    $progress.FinishOperationText = 'Go to specific temperature: 300 K'
    $progress.Elapsed = '1 day 23:59:59'
    $progress.Planned = '2 days 12:30:00'
    $progress.Counts = '123,456,789,012'
    $progress.Autosave = 'Wednesday, October 7, 2026 12:30 PM'
    $progress.IsIndeterminate = $true
    $progress.Margin = [System.Windows.Thickness]::new(0, 0, 0, 12)
    [void]$body.Children.Add($progress)
}
$instruments = Import-Card $shellDocument 'Instruments'
$instruments.DataContext = [pscustomobject]@{
    OpenConnectionsCommand = $null
    Instruments = @(
        [pscustomobject]@{ DisplayName = 'Spectrometer with a long instrument name'; StatusText = $(if ($populated) { 'Connected' } else { 'Disconnected' }); StatusVariant = [Mossbauer.Display.BadgeVariant]::Default },
        [pscustomobject]@{ DisplayName = 'Cryostat'; StatusText = $(if ($populated) { 'Simulated transition in progress' } else { 'Disconnected' }); StatusVariant = [Mossbauer.Display.BadgeVariant]::Simulated },
        [pscustomobject]@{ DisplayName = 'Source monitor'; StatusText = 'Disconnected'; StatusVariant = [Mossbauer.Display.BadgeVariant]::Error }
    )
}
[void]$body.Children.Add($instruments)
$source = Import-Card $shellDocument 'Source'
$source.DataContext = [pscustomobject]@{
    SourceIsotope = $(if ($populated) { '57Co' } else { '--' })
    SourceActivity = $(if ($populated) { '123,456.789 mCi' } else { '--' })
    SourceRetirementProgressText = $(if ($populated) { '75% life remaining' } else { 'No source' })
    SourceRetirementProgressValue = $(if ($populated) { 75.0 } else { 0.0 })
    SourceActivityReferenceDate = $(if ($populated) { 'Wednesday, October 7, 2026' } else { '--' })
    SourceRetirementDate = $(if ($populated) { 'Wednesday, December 31, 2031' } else { '--' })
}
[void]$body.Children.Add($source)
$installed = Import-Card $sourceDocument 'Installed source'
$installed.DataContext = [pscustomobject]@{
    Isotope = $(if ($populated) { '57Co' } else { '--' })
    SerialNumber = $(if ($populated) { 'LS-2026-123456789' } else { '--' })
    InitialStrength = $(if ($populated) { '123,456.789 mCi' } else { '--' })
    CurrentStrength = $(if ($populated) { '100,123.456 mCi' } else { '--' })
    ActivityReferenceDate = $(if ($populated) { 'Wednesday, October 7, 2026' } else { '--' })
    EstimatedReplacementDate = $(if ($populated) { 'Wednesday, December 31, 2031' } else { '--' })
    HasRecentMeasurement = $populated; HasInstalledSource = $populated
    LastMeasuredCount = '123,456,789,012'; LastCalculatedCount = '123,400,000,000'
    LastDeviation = '+12.345%'; ShowDeviationWarning = $populated
    LastMeasurementTimestamp = 'Wednesday, October 7, 2026 12:30 PM'
    SetUpSourceCommand = $null; ReplaceSourceCommand = $null; ExportSourceCommand = $null
}
[void]$body.Children.Add($installed)
$root.Tag = @{ Installed = $installed; Populated = $populated }
$bootstrap = $Application.Resources['MossbauerFixtureBootstrap']
@{
    Root = $root
    Evidence = @{
        Scenario = 'Presentation cards'; Theme = $Theme; State = $State
        Content = 'Source-sourced card snippets; compiled MeasurementProgressCard and display primitives; fixture-constrained widths'
        RepositoryRoot = $resolvedRepository; BuildModifiedUtc = $bootstrap.BuildModifiedUtc
        SourceFiles = @($shellPath, $sourcePath)
        Excludes = 'Full-page layout/scrolling, chart bindings, commands, device state, input automation'
    }
    AssertLayout = {
        param($Root, $Width, $Height)
        $counts = @{ Rows = 0; Badges = 0; Deviation = 0 }
        $sharedWidths = @{}
        $tolerance = 1 / [System.Windows.Media.VisualTreeHelper]::GetDpi($Root).DpiScaleX + 0.001
        function Inspect-Visual($Node) {
            if ($Node -is [Mossbauer.Display.KeyValueRow] -and $Node.ActualWidth -gt 0) {
                $counts.Rows++
                $grid = $Node.Content
                $label = $grid.Children[0]
                $value = $grid.Children[1]
                $column = $grid.ColumnDefinitions[2]
                $scope = $Node
                while ($scope -and ![System.Windows.Controls.Grid]::GetIsSharedSizeScope($scope)) {
                    $scope = [System.Windows.Media.VisualTreeHelper]::GetParent($scope)
                }
                if (!$scope -or !$column.SharedSizeGroup -or $column.MaxWidth -ne 150 -or
                    [Math]::Abs($grid.ColumnDefinitions[1].ActualWidth - 12) -gt $tolerance) {
                    throw 'Paired row lost its shared scope, value bound, or explicit spacer.'
                }
                $group = "$($scope.GetHashCode()):$($column.SharedSizeGroup)"
                if ($sharedWidths.ContainsKey($group) -and
                    [Math]::Abs($sharedWidths[$group] - $column.ActualWidth) -gt $tolerance) { throw 'Shared value columns drift within a card.' }
                $sharedWidths[$group] = $column.ActualWidth
                $left = $value.TranslatePoint([System.Windows.Point]::new(0, 0), $Node).X
                if ($value.ActualWidth -gt 150 + $tolerance -or $label.ActualWidth + 12 -gt $left + $tolerance -or
                    [Math]::Abs($left + $value.ActualWidth - $Node.ActualWidth) -gt $tolerance) { throw 'Paired row is unbounded, colliding, or not right-aligned.' }
                if ($Node.Key -eq 'Deviation' -and $Root.Tag.Populated) {
                    $counts.Deviation++
                    if ($Node.Value.Foreground.Color -ne $Node.FindResource('MossbauerErrorBrush').Color) { throw 'Custom Deviation foreground was lost.' }
                }
            }
            if ($Node -is [Mossbauer.Display.Badge] -and $Node.Parent -is [System.Windows.Controls.Grid] -and
                [System.Windows.Controls.Grid]::GetColumn($Node) -eq 2 -and $Node.ActualWidth -gt 0) {
                $counts.Badges++
                $grid = $Node.Parent
                $left = $Node.TranslatePoint([System.Windows.Point]::new(0, 0), $grid).X
                if ($Node.ActualWidth -gt 150 + $tolerance -or $grid.Children[0].ActualWidth + 12 -gt $left + $tolerance -or
                    [Math]::Abs($left + $Node.ActualWidth - $grid.ActualWidth) -gt $tolerance) { throw "Instrument badge geometry: width=$($Node.ActualWidth), label=$($grid.Children[0].ActualWidth), left=$left, grid=$($grid.ActualWidth)." }
            }
            for ($i = 0; $i -lt [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($Node); $i++) {
                Inspect-Visual ([System.Windows.Media.VisualTreeHelper]::GetChild($Node, $i))
            }
        }
        Inspect-Visual $Root
        if ($counts.Rows -lt 8 -or $counts.Badges -ne 3 -or
            ($Root.Tag.Populated -and $counts.Deviation -ne 1)) { throw 'Expected card details/badges are missing.' }
        if ($Root.Tag.Installed.ActualWidth -le 0 -or $Root.Tag.Installed.ActualWidth -gt 340.1) { throw 'Installed source card is missing or exceeds its bound.' }
        $last = $Root.Child.Children[$Root.Child.Children.Count - 1]
        if ($last.TranslatePoint([System.Windows.Point]::new(0, $last.ActualHeight), $Root).Y -gt $Height - 16) { throw 'Fixture height clips critical card content.' }
    }
}
