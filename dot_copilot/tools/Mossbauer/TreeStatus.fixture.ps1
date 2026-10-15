<#
.SYNOPSIS
Standalone Mossbauer project-tree rendering and status/layout checks.

.DESCRIPTION
Use with Render-WpfFixture.ps1 and explicit FixtureParameters:
RepositoryRoot = the Mossbauer repository; Theme = Light or Dark.
Uses current MainWindow tree markup and compiled ProjectMeasurementTree/status
models without constructing the shell, Prism regions, charts, or hardware.
Event setters are omitted in the fixture; full-app commands, keyboard navigation,
and mouse handling are not validated.

Status model asserted: a single ProjectExplorerStatusIcon per row shows
check (success brush) for completed, circle-slash (warning brush) for canceled,
and circled X (error brush) for failed. Created and running rows show no icon;
running rows show the Running badge. The unsaved dot is a separate axis and is
asserted independently. Tooltip text must equal the automation name.

Scenario: status x unsaved matrix, running + unsaved, nested sequences
(completed, interrupted, failed parents), selection, and long names.

Minimum size is 240 x 260 DIPs; 300 x 640 shows every row without scrolling.
Assertions cover icon glyph/brush/visibility, right-edge alignment of status
slots, dot visibility, one Running badge, and no keyboard stop on the icon.
They do not assert scrollbar interaction; at narrow heights inspect the PNG.

.EXAMPLE
pwsh -NoProfile -STA -Command '& "$HOME\.copilot\tools\Render-WpfFixture.ps1" -FixturePath "$HOME\.copilot\tools\Mossbauer\TreeStatus.fixture.ps1" -AssemblyDirectory "D:\repos\Mossbauer\Mossbauer\bin\Debug\net8.0-windows" -Width 300 -Height 640 -OutputPath "$env:TEMP\tree-light.png" -CaptureOnFailure -FixtureParameters @{ RepositoryRoot = "D:\repos\Mossbauer"; Theme = "Light" }'

.NOTES
Repeatable smoke check: use fresh processes and new output paths, in both
themes, at 300 x 640. Inspect PNGs and the returned assertion/binding/DPI
evidence. Rebuild first only when the compiled inputs changed; never build
concurrently against the renderer's AssemblyDirectory.
Expected refusals: missing RepositoryRoot or source tree/template, unknown Theme,
width below 240 or height below 260. Confirm the command fails and produces no
passing image. Diagnostic .failure artifacts, if enabled, are not passing evidence.
Delete only the output artifacts you created after inspection.
#>
param(
    $AssemblyDirectory, $Application, $Width, $Height,
    [string]$RepositoryRoot,
    [ValidateSet('Light', 'Dark')][string]$Theme = 'Dark'
)
$ErrorActionPreference = 'Stop'
if (!$RepositoryRoot -or !(Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
    throw 'RepositoryRoot must name the Mossbauer repository.'
}
if ($Width -lt 240 -or $Height -lt 260) { throw 'Tree fixture requires at least 240 x 260 DIPs.' }
$sourcePath = Join-Path (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath 'Mossbauer\Shell\MainWindow.xaml'
if (!(Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Missing source markup: $sourcePath" }
$document = [xml](Get-Content -LiteralPath $sourcePath -Raw)
$templates = $document.SelectNodes("//*[local-name()='HierarchicalDataTemplate' and @*[local-name()='Key']='ProjectExplorerItemTemplate']")
$trees = $document.SelectNodes("//*[local-name()='RadTreeView']")
if ($templates.Count -ne 1 -or $trees.Count -ne 1) { throw 'Expected exactly one project-tree template and RadTreeView.' }
$template = $templates[0]
$treeNode = $trees[0]
& "$PSScriptRoot\Initialize-MossbauerFixture.ps1" -AssemblyDirectory $AssemblyDirectory -Application $Application -Theme $Theme
foreach ($event in @($treeNode.SelectNodes(".//*[local-name()='EventSetter']"))) {
    [void]$event.ParentNode.RemoveChild($event)
}
$prefix = '<Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:display="clr-namespace:Mossbauer.Display;assembly=Mossbauer" xmlns:measurement="clr-namespace:LakeShore.Mossbauer.SpectrumMeasurement;assembly=Mossbauer" xmlns:telerik="http://schemas.telerik.com/2008/xaml/presentation" xmlns:telerikTheming="clr-namespace:Telerik.Windows.Controls.Theming.Helpers;assembly=Telerik.Windows.Controls">'
$markup = $prefix + '<Grid.Resources>' + $template.OuterXml + '</Grid.Resources>' + $treeNode.OuterXml + '</Grid>'
$markup = $markup -replace 'clr-namespace:Mossbauer.Display(?=["''])', 'clr-namespace:Mossbauer.Display;assembly=Mossbauer'
$markup = $markup -replace 'clr-namespace:LakeShore.Mossbauer.SpectrumMeasurement(?=["''])', 'clr-namespace:LakeShore.Mossbauer.SpectrumMeasurement;assembly=Mossbauer'
$root = [System.Windows.Markup.XamlReader]::Parse($markup)
$root.Margin = [System.Windows.Thickness]::new(15, 10, 15, 10)
$root.SetResourceReference([System.Windows.Controls.Panel]::BackgroundProperty, 'MossbauerCardBackgroundBrush')

$summaries = [System.Collections.Generic.List[LakeShore.Mossbauer.SpectrumMeasurement.SpectrumMeasurementSummary]]::new()
function Add-Summary($Name, $Type, $Kind, $Status, $Parent = $null, $Index = $null) {
    $summary = [LakeShore.Mossbauer.SpectrumMeasurement.SpectrumMeasurementSummary]::new()
    $summary.MeasurementId = [guid]::NewGuid()
    $summary.MeasurementName = $Name
    $summary.RelativePath = $Name
    $summary.MeasurementType = $Type
    $summary.NodeKind = $Kind
    $summary.Status = $Status
    $summary.HasResults = $Status -ne 'Created'
    $summary.ParentMeasurementId = $Parent
    $summary.ExecutionIndex = $Index
    if ($null -ne $Index) { $summary.TargetTemperatureKelvin = 100 + 100 * $Index }
    $summaries.Add($summary)
    return $summary.MeasurementId
}
[void](Add-Summary 'Completed' 'FixedTemperature' 'Standalone' 'Completed')
[void](Add-Summary 'Completed + unsaved' 'FixedTemperature' 'Standalone' 'Completed')
[void](Add-Summary 'Canceled' 'FixedTemperature' 'Standalone' 'Canceled')
[void](Add-Summary 'Failed' 'FixedTemperature' 'Standalone' 'Failed')
[void](Add-Summary 'Failed + unsaved' 'FixedTemperature' 'Standalone' 'Failed')
[void](Add-Summary 'Created' 'FixedTemperature' 'Standalone' 'Created')
[void](Add-Summary 'Created + unsaved' 'FixedTemperature' 'Standalone' 'Created')
[void](Add-Summary 'Running + unsaved with a very long name' 'FixedTemperature' 'Standalone' 'Completed')
[void](Add-Summary 'Completed with a very long name that must trim' 'FixedTemperature' 'Standalone' 'Completed')
$doneParent = Add-Summary 'Sequence completed' 'VariableTemperature' 'VariableTemperatureParent' 'Completed'
[void](Add-Summary '1 K' 'VariableTemperature' 'VariableTemperatureChild' 'Completed' $doneParent 0)
[void](Add-Summary '2 K' 'VariableTemperature' 'VariableTemperatureChild' 'Completed' $doneParent 1)
$parentId = Add-Summary 'Sequence interrupted' 'VariableTemperature' 'VariableTemperatureParent' 'Canceled'
[void](Add-Summary '6 K' 'VariableTemperature' 'VariableTemperatureChild' 'Completed' $parentId 0)
[void](Add-Summary '7 K' 'VariableTemperature' 'VariableTemperatureChild' 'Canceled' $parentId 1)
[void](Add-Summary '8 K' 'VariableTemperature' 'VariableTemperatureChild' 'Created' $parentId 2)
$failedParent = Add-Summary 'Sequence failed' 'VariableTemperature' 'VariableTemperatureParent' 'Failed'
[void](Add-Summary '3 K' 'VariableTemperature' 'VariableTemperatureChild' 'Completed' $failedParent 0)
$tree = [LakeShore.Mossbauer.SpectrumMeasurement.ProjectMeasurementTree]::new()
$tree.Refresh($summaries)
foreach ($group in $tree.Groups) { $group.IsExpanded = $true }
foreach ($m in $tree.Measurements) { $m.IsExpanded = $true }
function Set-Dirty($Label) {
    $item = @($tree.Measurements | Where-Object Label -EQ $Label)[0]
    $item.HasOwnUnsavedChanges = $true
    $item.IsDirty = $true
}
Set-Dirty 'Completed + unsaved'
Set-Dirty 'Failed + unsaved'
Set-Dirty 'Created + unsaved'
Set-Dirty 'Running + unsaved with a very long name'
@($tree.Measurements | Where-Object Label -Like 'Running +*')[0].IsRunning = $true
$selected = @($tree.Measurements | Where-Object Label -EQ 'Canceled')[0]
$selected.IsSelected = $true
$root.DataContext = [pscustomobject]@{
    ProjectExplorerItems = $tree.Groups
    SelectedProjectExplorerItem = $selected
    SpectrumMeasurement = [pscustomobject]@{ HasOpenProject = $true }
}

@{
    Root = $root
    Evidence = @{ Theme = $Theme; Source = 'Current MainWindow tree markup and compiled tree/status viewmodels'; Scenario = 'status x unsaved matrix, running+unsaved, nested sequences, long names' }
    AssertLayout = {
        param($Root, $Width, $Height)
        function Get-Visuals($Element) {
            $Element
            for ($i = 0; $i -lt [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($Element); $i++) {
                Get-Visuals ([System.Windows.Media.VisualTreeHelper]::GetChild($Element, $i))
            }
        }
        $visuals = @(Get-Visuals $Root)
        $tol = 1 / [System.Windows.Media.VisualTreeHelper]::GetDpi($Root).DpiScaleX
        $icons = @($visuals | Where-Object { $_ -is [System.Windows.Controls.TextBlock] -and $_.Name -eq 'ProjectExplorerStatusIcon' })
        $dots = @($visuals | Where-Object { $_ -is [System.Windows.Shapes.Ellipse] -and $_.Name -eq 'ProjectExplorerUnsavedDot' })
        $glyphs = @{ Completed = [string][char]0xE73E; Canceled = [string][char]0xE733; Failed = [string][char]0xEA39 }
        $brushes = @{ Completed = 'MossbauerSuccessBrush'; Canceled = 'MossbauerWarningBrush'; Failed = 'MossbauerErrorBrush' }
        $rights = @(); $shown = 0
        foreach ($icon in $icons) {
            $item = $icon.DataContext
            if ($icon.Focusable) { throw 'Status icon adds a keyboard stop.' }
            $running = $item.IsRunning -and !$item.HasFailureIndicator
            $expected = $item.IsMeasurement -and !$running -and ($item.ShowCompletionIndicator -or $item.ShowFinalizedChildIndicator -or $item.ShowSuccessfulMeasurementIndicator -or $item.Status -in @('Canceled', 'Failed') -or $item.HasFailureIndicator)
            if (($icon.Visibility -eq 'Visible') -ne $expected) { throw "Incorrect icon visibility: $($item.Label) vis=$($icon.Visibility)" }
            if ($item.IsMeasurement) {
                $p = $icon.TranslatePoint([System.Windows.Point]::new(0, 0), $Root)
                $rights += $p.X + $icon.ActualWidth
                Write-Host ("{0}: status={1} vis={2} glyph={3:X} tip='{4}'" -f $item.Label, $item.Status, $icon.Visibility, [int][char]$icon.Text[0], $icon.ToolTip)
            }
            if ($expected) {
                $shown++
                $kind = if ($item.HasFailureIndicator) { 'Failed' } elseif ($item.Status -eq 'Canceled') { 'Canceled' } else { 'Completed' }
                if ($icon.Text -ne $glyphs[$kind]) { throw "Wrong glyph for $($item.Label)" }
                if ($icon.Foreground.Color -ne $Root.FindResource($brushes[$kind]).Color) { throw "Wrong brush for $($item.Label)" }
                if (!$icon.ToolTip -or [System.Windows.Automation.AutomationProperties]::GetName($icon) -ne $icon.ToolTip) { throw "Tooltip/automation name mismatch: $($item.Label)" }
            }
        }
        foreach ($dot in $dots) {
            if (($dot.Visibility -eq 'Visible') -ne [bool]$dot.DataContext.IsDirty) { throw "Dot visibility wrong: $($dot.DataContext.Label)" }
        }
        $range = $rights | Measure-Object -Minimum -Maximum
        if ($range.Maximum - $range.Minimum -gt $tol) { throw "Status icons misaligned by $($range.Maximum - $range.Minimum)" }
        if ($range.Maximum -gt $Root.ActualWidth) { throw 'Status extends beyond viewport.' }
        $badges = @($visuals | Where-Object { $_ -is [Mossbauer.Display.Badge] -and $_.BadgeContent -eq 'Running' -and $_.Visibility -eq 'Visible' })
        if ($badges.Count -ne 1) { throw 'Expected one running badge.' }
        Write-Host "shown=$shown icons=$($icons.Count) dotsVisible=$(@($dots | Where-Object Visibility -eq 'Visible').Count)"
    }
}
