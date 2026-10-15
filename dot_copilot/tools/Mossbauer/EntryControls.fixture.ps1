<#
.SYNOPSIS
Standalone Mossbauer entry-control rendering and geometry checks.

.DESCRIPTION
Use with Render-WpfFixture.ps1 and an existing application build. FixtureParameters:
Theme = Light or Dark; State = All, Normal, Disabled, ReadOnly, or Invalid.
Minimum size: 220 x 500 DIPs. Uses compiled controls/styles and representative
large values/units. Checks visible input height, unit reservation, brushes, and
actual field validation adorners. No product application or hardware startup.
This is not mouse/keyboard automation: caret, drag, undo, commands, high contrast,
and theme switching within a live application remain separate manual checks.

.EXAMPLE
pwsh -NoProfile -STA -Command '& "$HOME\.copilot\tools\Render-WpfFixture.ps1" -FixturePath "$HOME\.copilot\tools\Mossbauer\EntryControls.fixture.ps1" -AssemblyDirectory "D:\repos\Mossbauer\Mossbauer\bin\Debug\net8.0-windows" -Width 300 -Height 540 -OutputPath "$env:TEMP\entries-dark.png" -FixtureParameters @{ Theme = "Dark"; State = "All" }'

.NOTES
Repeatable smoke check: run the example in a fresh process for both themes with
new PNG paths under the OS temp directory; the renderer asserts geometry and
refuses binding errors. Inspect each PNG and returned evidence. Expected refusals:
unknown Theme/State and width below 220 or height below 500; use a fresh output
path and confirm no image was written. Delete only the images you created afterward.
All mixes normal/disabled/read-only entries plus an invalid field; Invalid adds
the invalid field to normal reference entries. Other states apply to all entries.
No unit-test project integration.
#>
param(
    $AssemblyDirectory, $Application, $Width, $Height,
    [ValidateSet('Light', 'Dark')][string]$Theme = 'Light',
    [ValidateSet('All', 'Normal', 'Disabled', 'ReadOnly', 'Invalid')][string]$State = 'All'
)
$ErrorActionPreference = 'Stop'
if ($Width -lt 220 -or $Height -lt 500) { throw 'Entry fixture requires at least 220 x 500 DIPs.' }
& "$PSScriptRoot\Initialize-MossbauerFixture.ps1" -AssemblyDirectory $AssemblyDirectory -Application $Application -Theme $Theme

$root = [System.Windows.Controls.Border]::new()
$root.SetResourceReference([System.Windows.Controls.Border]::BackgroundProperty, 'MossbauerContentBackgroundBrush')
$body = [System.Windows.Controls.StackPanel]::new()
$body.Margin = [System.Windows.Thickness]::new(16)
$body.HorizontalAlignment = 'Left'
$body.Width = 188
$root.Child = $body
$reference = [System.Windows.Controls.TextBox]::new()
$reference.Style = $Application.FindResource('MossbauerTextBoxStyle')
$reference.Text = '123456789012345'
$reference.Width = 170
$reference.HorizontalAlignment = 'Left'
$reference.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
$reference.IsEnabled = $State -ne 'Disabled'
$reference.IsReadOnly = $State -eq 'ReadOnly'
[void]$body.Children.Add($reference)
$combo = [Telerik.Windows.Controls.RadComboBox]::new()
$combo.Style = $Application.FindResource('MossbauerComboBoxStyle')
$combo.Width = 170
$combo.HorizontalAlignment = 'Left'
$combo.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
$combo.ItemsSource = [Enum]::GetValues([LakeShore.Mossbauer.SpectrumMeasurement.SpectrumCountingMode])
$combo.SelectedItem = [LakeShore.Mossbauer.SpectrumMeasurement.SpectrumCountingMode]::FixedTimeCount
$combo.IsEnabled = $State -ne 'Disabled'
$combo.IsReadOnly = $State -eq 'ReadOnly'
$combo.ItemTemplate = [System.Windows.Markup.XamlReader]::Parse(@'
<DataTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:infra="clr-namespace:LakeShore.MLInfrastructure;assembly=MLInfrastructure">
    <DataTemplate.Resources>
        <infra:EnumDescriptionConverter x:Key="Description" />
    </DataTemplate.Resources>
    <TextBlock Text="{Binding Converter={StaticResource Description}}" />
</DataTemplate>
'@)
[void]$body.Children.Add($combo)
$entries = [System.Collections.Generic.List[object]]::new()
$index = 0
foreach ($unit in @('K', 'h', 'mm/s', 'Count/Ch', 'mCi')) {
    $entry = [LakeShore.WpfControls.GenericUnitsEntryControl]::new()
    $entry.Width = 170
    $entry.HorizontalAlignment = 'Left'
    $entry.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
    $entry.Units = $unit
    $entry.UnitsOffset = 4
    $entry.Digits = 15
    $entry.Value = 123456789012345
    $entryState = if ($State -eq 'All') { @('Normal', 'Normal', 'Normal', 'Disabled', 'ReadOnly')[$index] } else { $State }
    $entry.IsEnabled = $entryState -ne 'Disabled'
    $entry.IsReadOnly = $entryState -eq 'ReadOnly'
    [Mossbauer.Themes.MossbauerControlTheme]::SetApplyToUnitsEntry($entry, $true)
    [void]$body.Children.Add($entry)
    $entries.Add($entry)
    $index++
}
$invalidEntry = $null
if ($State -in @('All', 'Invalid')) {
    $setup = [LakeShore.Mossbauer.SpectrumMeasurement.MeasurementSetupViewModel]::new()
    $setup.MaximumVelocity = 31
    $invalidEntry = [LakeShore.WpfControls.GenericUnitsEntryControl]::new()
    $invalidEntry.Width = 170
    $invalidEntry.HorizontalAlignment = 'Left'
    $invalidEntry.Units = 'mm/s'
    $invalidEntry.UnitsOffset = 4
    $binding = [System.Windows.Data.Binding]::new('MaximumVelocity')
    $binding.Source = $setup
    $binding.Mode = 'TwoWay'
    $binding.ValidatesOnNotifyDataErrors = $true
    [void]$invalidEntry.SetBinding([LakeShore.WpfControls.GenericUnitsEntryControl]::ValueProperty, $binding)
    [Mossbauer.Themes.MossbauerControlTheme]::SetApplyToUnitsEntry($invalidEntry, $true)
    [void]$body.Children.Add($invalidEntry)
    $entries.Add($invalidEntry)
}
$measurements = @{}
$root.Tag = @{ Reference = $reference; Combo = $combo; Entries = $entries; Invalid = $invalidEntry; Measurements = $measurements }
$bootstrap = $Application.Resources['MossbauerFixtureBootstrap']
@{
    Root = $root
    Evidence = @{
        Scenario = 'Entry controls'; Theme = $Theme; State = $State
        Content = 'Compiled controls and application styles; representative data'
        BuildModifiedUtc = $bootstrap.BuildModifiedUtc
        Measurements = $measurements
        Excludes = 'Live input automation, full views, hardware, high contrast, other DPI settings'
    }
    AssertLayout = {
        param($Root, $Width, $Height)
        $reference = $Root.Tag.Reference
        $tolerance = 1 / [System.Windows.Media.VisualTreeHelper]::GetDpi($Root).DpiScaleY + 0.001
        if ($reference.MinHeight -lt 32 -or $Root.Tag.Combo.MinHeight -lt 32 -or
            [Math]::Abs($reference.ActualHeight - 32) -gt $tolerance -or
            [Math]::Abs($Root.Tag.Combo.ActualHeight - $reference.ActualHeight) -gt $tolerance) {
            throw "Reference heights differ: textbox=$($reference.ActualHeight), combo=$($Root.Tag.Combo.ActualHeight); expected 32 DIPs."
        }
        $Root.Tag.Measurements.ReferenceHeight = $reference.ActualHeight
        $Root.Tag.Measurements.ComboHeight = $Root.Tag.Combo.ActualHeight
        $Root.Tag.Measurements.UnitsHeights = @()
        foreach ($entry in $Root.Tag.Entries) {
            $textBox = $entry.TextBox
            $units = $textBox.Template.FindName('PART_Units', $textBox)
            $viewport = $textBox.Template.FindName('PART_ContentHost', $textBox)
            $border = $textBox.Template.FindName('Border', $textBox)
            if (!$units -or !$viewport -or !$border) { throw 'Expected vendor template parts are missing.' }
            if ($textBox.MinHeight -lt 32 -or [Math]::Abs($textBox.ActualHeight - $reference.ActualHeight) -gt $tolerance -or
                [Math]::Abs($border.ActualHeight - $reference.ActualHeight) -gt $tolerance) { throw 'Visible units entry height differs from the reference.' }
            $Root.Tag.Measurements.UnitsHeights += @{ Unit = $entry.Units; TextBox = $textBox.ActualHeight; Border = $border.ActualHeight }
            if ($units.Text -ne $entry.Units -or $units.Padding.Right -lt 4 -or
                $units.Padding.Left -ne 4 -or $viewport.ViewportWidth -le 0) { throw 'Invalid units text, inset, or reservation.' }
            $unitsLeft = $units.TranslatePoint([System.Windows.Point]::new(0, 0), $textBox).X
            $valueRight = $viewport.TranslatePoint([System.Windows.Point]::new($viewport.ActualWidth, 0), $textBox).X
            if ($valueRight -gt $unitsLeft + 0.1) { throw 'Numeric viewport overlaps units.' }
            $focus = $textBox.Template.FindName('FocusedVisual', $textBox)
            if (!$focus -or $focus.BorderBrush.Color -ne $entry.FindResource('MossbauerAccentBrush').Color) { throw 'Focus resource is not the application accent.' }
            if (!$entry.IsEnabled -and ($textBox.Foreground.Color -ne $entry.FindResource('MossbauerDisabledTextBrush').Color -or
                $border.Opacity -ne 1)) { throw 'Disabled contrast is not driven by application brushes.' }
            if (($entry.IsReadOnly -or !$entry.IsEnabled) -and
                $textBox.Background.Color -ne $entry.FindResource('MossbauerInputReadOnlyBackgroundBrush').Color) {
                throw 'Read-only/disabled input background is not the application brush.'
            }
        }
        if ($Root.Tag.Invalid) {
            $entry = $Root.Tag.Invalid
            $layer = [System.Windows.Documents.AdornerLayer]::GetAdornerLayer($entry)
            if (![System.Windows.Controls.Validation]::GetHasError($entry) -or !$layer -or !$layer.GetAdorners($entry)) {
                throw 'Actual numeric field validation chrome is missing.'
            }
        }
        $last = $Root.Child.Children[$Root.Child.Children.Count - 1]
        if ($last.TranslatePoint([System.Windows.Point]::new(0, $last.ActualHeight), $Root).Y -gt $Height - 16) {
            throw 'Fixture height clips entry content.'
        }
    }
}
