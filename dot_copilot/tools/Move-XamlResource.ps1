<#
.SYNOPSIS
Moves keyed XAML resources from one file into a ResourceDictionary file.

.DESCRIPTION
Text-based move that preserves the moved markup. Each Key must match exactly one
x:Key in Source. Source and Target are checked for well-formed XML before and
after the move; nothing is written if any check fails.

Refuses resources containing event attributes, EventSetter handlers,
x:Name/Name, or ElementName bindings unless -AllowEventHandlers is specified.

Copies the xmlns declarations that the moved blocks use. Creates Target, and its
directory, when missing. Unless -NoMergeUpdate is specified, adds a merged
dictionary reference to Target in Source (relative path by default); an existing
reference is left unchanged.

Rewrites Source and Target as UTF-8 without BOM. Build the consuming project
afterward; this tool does not prove that moved resources resolve at runtime.

.PARAMETER Source
XAML file containing the resources to move.

.PARAMETER Target
ResourceDictionary file to receive the resources. Created if missing.

.PARAMETER Key
One or more x:Key values to move.

.PARAMETER DictionarySource
Source value for the merged dictionary reference. Defaults to the path of
Target relative to Source.

.PARAMETER AllowEventHandlers
Allow moving behavior-coupled resources. Use only after confirming the move
preserves behavior.

.PARAMETER NoMergeUpdate
Do not add a merged dictionary reference to Source.

.PARAMETER SelfTest
Run built-in checks in a disposable temporary directory and clean up.

.PARAMETER DryRun
Validate and print the planned move without writing files.

.EXAMPLE
pwsh -NoProfile -File "$HOME\.copilot\tools\Move-XamlResource.ps1" -Source .\Views\StatusView.xaml -Target .\Views\StatusView.Resources.xaml -Key StatusTemplate -DryRun

.EXAMPLE
pwsh -NoProfile -Command '& "$HOME\.copilot\tools\Move-XamlResource.ps1" -Source .\Views\StatusView.xaml -Target .\Views\StatusView.Resources.xaml -Key StatusTemplate, StatusStyle'

Multiple keys require -Command. With -File, "A,B" is passed as one key.

.EXAMPLE
pwsh -NoProfile -File "$HOME\.copilot\tools\Move-XamlResource.ps1" -SelfTest
#>
param(
    [string]$Source,

    [string]$Target,

    [string[]]$Key,

    [string]$DictionarySource,

    [switch]$AllowEventHandlers,

    [switch]$NoMergeUpdate,

    [switch]$SelfTest,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Read-TextFile {
    param([string]$Path)

    [System.IO.File]::ReadAllText($Path)
}

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Text
    )

    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Assert-WellFormedXml {
    param(
        [string]$Text,
        [string]$Description
    )

    $settings = [System.Xml.XmlReaderSettings]::new()
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit

    try {
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($Text), $settings)
        while ($reader.Read()) { }
        $reader.Dispose()
    }
    catch {
        throw "$Description is not well-formed XML. $($_.Exception.Message)"
    }
}

function Get-XmlnsMap {
    param([string]$Text)

    $rootMatch = [regex]::Match($Text, '<[A-Za-z_][\w:.-]*(?:\s+[^<>]*)?>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $rootMatch.Success) {
        throw "Could not find root element."
    }

    $map = @{}
    foreach ($match in [regex]::Matches($rootMatch.Value, '\sxmlns(?::(?<prefix>[A-Za-z_][\w.-]*))?="(?<uri>[^"]+)"')) {
        $prefix = $match.Groups["prefix"].Value
        if ([string]::IsNullOrEmpty($prefix)) {
            $prefix = ""
        }

        $map[$prefix] = $match.Groups["uri"].Value
    }

    $map
}

function Add-MissingXmlns {
    param(
        [string]$Text,
        [hashtable]$SourceXmlns,
        [string[]]$Prefixes
    )

    $targetXmlns = Get-XmlnsMap $Text
    $missing = @(
        $Prefixes |
            Where-Object { $SourceXmlns.ContainsKey($_) -and -not $targetXmlns.ContainsKey($_) } |
            Sort-Object -Unique
    )

    if ($missing.Count -eq 0) {
        return $Text
    }

    $rootMatch = [regex]::Match($Text, '<[A-Za-z_][\w:.-]*(?:\s+[^<>]*)?>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $rootMatch.Success) {
        throw "Could not find target root element."
    }

    $insert = ""
    foreach ($prefix in $missing) {
        if ([string]::IsNullOrEmpty($prefix)) {
            continue
        }

        $insert += "`r`n    xmlns:$prefix=""$($SourceXmlns[$prefix])"""
    }

    if ([string]::IsNullOrEmpty($insert)) {
        return $Text
    }

    $updatedRoot = $rootMatch.Value -replace '>$', "$insert>"
    $Text.Remove($rootMatch.Index, $rootMatch.Length).Insert($rootMatch.Index, $updatedRoot)
}

function Get-UsedXmlnsPrefixes {
    param([string]$Text)

    @(
        foreach ($match in [regex]::Matches($Text, '(?<![\w.-])(?<prefix>[A-Za-z_][\w.-]*):[A-Za-z_][\w.-]*')) {
            $prefix = $match.Groups["prefix"].Value
            if ($prefix -ne "http" -and $prefix -ne "https" -and $prefix -ne "xml") {
                $prefix
            }
        }
    ) | Sort-Object -Unique
}

function Assert-NoBehaviorCoupling {
    param(
        [string]$Block,
        [string]$Key
    )

    $findings = @()

    $eventAttributePattern = '\s(?<name>Loaded|Unloaded|Initialized|Click|Checked|Unchecked|SelectionChanged|TextChanged|ValueChanged|SourceUpdated|TargetUpdated|DropDownOpened|DropDownClosed|Mouse\w+|PreviewMouse\w+|Key\w+|PreviewKey\w+)\s*=\s*"(?<handler>[A-Za-z_]\w*)"'
    foreach ($match in [regex]::Matches($Block, $eventAttributePattern)) {
        $findings += "$($match.Groups["name"].Value)=""$($match.Groups["handler"].Value)"""
    }

    foreach ($match in [regex]::Matches($Block, '\sHandler\s*=\s*"(?<handler>[A-Za-z_]\w*)"')) {
        $findings += "EventSetter Handler=""$($match.Groups["handler"].Value)"""
    }

    foreach ($match in [regex]::Matches($Block, '\s(?:x:Name|Name)\s*=\s*"(?<name>[^"]+)"')) {
        $findings += "named element ""$($match.Groups["name"].Value)"""
    }

    foreach ($match in [regex]::Matches($Block, 'ElementName\s*=\s*(?<name>[^,}\s]+)')) {
        $findings += "ElementName binding ""$($match.Groups["name"].Value)"""
    }

    if ($findings.Count -gt 0) {
        throw "Resource '$Key' contains behavior-coupled XAML: $($findings -join ', '). Use -AllowEventHandlers only after confirming the move preserves behavior."
    }
}

function Find-ResourceBlock {
    param(
        [string]$Text,
        [string]$Key
    )

    $keyPattern = 'x:Key\s*=\s*"' + [regex]::Escape($Key) + '"'
    $keyMatches = @([regex]::Matches($Text, $keyPattern))
    if ($keyMatches.Count -eq 0) {
        throw "Could not find x:Key=""$Key"" in source."
    }

    if ($keyMatches.Count -gt 1) {
        throw "Found multiple x:Key=""$Key"" matches in source. Move one resource at a time after making keys unique."
    }

    $keyIndex = $keyMatches[0].Index
    $start = $Text.LastIndexOf("<", $keyIndex)
    if ($start -lt 0) {
        throw "Could not find start tag for x:Key=""$Key""."
    }

    $startTagMatch = [regex]::Match($Text.Substring($start), '^<(?<name>[A-Za-z_][\w:.-]*)(?:\s+[^<>]*)?>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $startTagMatch.Success) {
        throw "Could not parse start tag for x:Key=""$Key""."
    }

    $elementName = $startTagMatch.Groups["name"].Value
    if ($startTagMatch.Value.EndsWith("/>")) {
        return [pscustomobject]@{
            Start = $start
            End = $start + $startTagMatch.Length
            Text = $Text.Substring($start, $startTagMatch.Length)
        }
    }

    $tokenPattern = '<(?<slash>/)?' + [regex]::Escape($elementName) + '(?=\s|/?>)(?:\s+[^<>]*)?(?<self>/)?>'
    $depth = 0
    foreach ($match in [regex]::Matches($Text.Substring($start), $tokenPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        if ($match.Groups["slash"].Success) {
            $depth--
        }
        elseif ($match.Groups["self"].Success) {
            # Self-closing nested tag does not change depth.
        }
        else {
            $depth++
        }

        if ($depth -eq 0) {
            $end = $start + $match.Index + $match.Length
            return [pscustomobject]@{
                Start = $start
                End = $end
                Text = $Text.Substring($start, $end - $start)
            }
        }
    }

    throw "Could not find end tag for resource x:Key=""$Key""."
}

function Normalize-ResourceIndent {
    param([string]$Block)

    $lines = ($Block.Trim("`r", "`n") -split "\r?\n")
    $indents = @(
        foreach ($line in $lines) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                ([regex]::Match($line, '^\s*')).Length
            }
        }
    )

    $minIndent = 0
    if ($indents.Count -gt 0) {
        $minIndent = ($indents | Measure-Object -Minimum).Minimum
    }

    ($lines | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_)) {
            ""
        }
        else {
            "    " + $_.Substring([Math]::Min($minIndent, $_.Length))
        }
    }) -join "`r`n"
}

function Remove-ResourceBlock {
    param(
        [string]$Text,
        [int]$Start,
        [int]$End
    )

    while ($Start -gt 0 -and ($Text[$Start - 1] -eq "`n" -or $Text[$Start - 1] -eq "`r")) {
        $Start--
    }

    while ($End -lt $Text.Length -and ($Text[$End] -eq "`n" -or $Text[$End] -eq "`r")) {
        $End++
    }

    $Text.Remove($Start, $End - $Start)
}

function New-ResourceDictionaryText {
    param([hashtable]$SourceXmlns)

    $defaultXmlns = $SourceXmlns[""]
    if ([string]::IsNullOrWhiteSpace($defaultXmlns)) {
        $defaultXmlns = "http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    }

    $xXmlns = $SourceXmlns["x"]
    if ([string]::IsNullOrWhiteSpace($xXmlns)) {
        $xXmlns = "http://schemas.microsoft.com/winfx/2006/xaml"
    }

    @"
<ResourceDictionary
    xmlns="$defaultXmlns"
    xmlns:x="$xXmlns">
</ResourceDictionary>
"@
}

function Add-ResourcesToTarget {
    param(
        [string]$TargetText,
        [string[]]$Blocks
    )

    $closing = "</ResourceDictionary>"
    $closingIndex = $TargetText.LastIndexOf($closing)
    if ($closingIndex -lt 0) {
        throw "Target does not contain a closing ResourceDictionary tag."
    }

    $insert = "`r`n" + (($Blocks | ForEach-Object { Normalize-ResourceIndent $_ }) -join "`r`n`r`n") + "`r`n"
    $TargetText.Insert($closingIndex, $insert)
}

function Get-DefaultDictionarySource {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )

    $sourceDirectory = Split-Path -Parent $SourcePath
    $relative = [System.IO.Path]::GetRelativePath($sourceDirectory, $TargetPath)
    $relative.Replace("\", "/")
}

function Add-MergedDictionary {
    param(
        [string]$Text,
        [string]$DictionarySource
    )

    if ($Text -match [regex]::Escape($DictionarySource)) {
        return $Text
    }

    $mergedEntry = "                <ResourceDictionary Source=""$DictionarySource"" />"

    $mergedMatch = [regex]::Match($Text, '<ResourceDictionary\.MergedDictionaries>\s*', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($mergedMatch.Success) {
        return $Text.Insert($mergedMatch.Index + $mergedMatch.Length, $mergedEntry + "`r`n")
    }

    $dictionaryMatch = [regex]::Match($Text, '<ResourceDictionary(?:\s+[^<>]*)?>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($dictionaryMatch.Success -and $Text.Substring(0, $dictionaryMatch.Index) -match '^\s*$') {
        $insert = @"

    <ResourceDictionary.MergedDictionaries>
        <ResourceDictionary Source="$DictionarySource" />
    </ResourceDictionary.MergedDictionaries>
"@
        return $Text.Insert($dictionaryMatch.Index + $dictionaryMatch.Length, $insert)
    }

    $resourcesMatch = [regex]::Match($Text, '(?<indent>\s*)<(?<name>[A-Za-z_][\w:.-]*\.Resources)>\s*', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $resourcesMatch.Success) {
        throw "Could not find a *.Resources element to merge the target dictionary into."
    }

    $resourcesName = $resourcesMatch.Groups["name"].Value
    $closingTag = "</$resourcesName>"
    $closingIndex = $Text.IndexOf($closingTag, $resourcesMatch.Index)
    if ($closingIndex -lt 0) {
        throw "Could not find closing $closingTag."
    }

    $contentStart = $resourcesMatch.Index + $resourcesMatch.Length
    $content = $Text.Substring($contentStart, $closingIndex - $contentStart).Trim("`r", "`n")
    $indentedContent = ""
    if (-not [string]::IsNullOrWhiteSpace($content)) {
        $indentedContent = ($content -split "\r?\n" | ForEach-Object {
            if ([string]::IsNullOrWhiteSpace($_)) { "" } else { "    $_" }
        }) -join "`r`n"
        $indentedContent = "`r`n" + $indentedContent
    }

    $replacement = @"
$($resourcesMatch.Groups["indent"].Value)<$resourcesName>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="$DictionarySource" />
            </ResourceDictionary.MergedDictionaries>$indentedContent
        </ResourceDictionary>
"@

    $Text.Remove($resourcesMatch.Index, $closingIndex - $resourcesMatch.Index).Insert($resourcesMatch.Index, $replacement)
}

function Assert-Condition {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-SelfTest {
    $temp = Join-Path $env:TEMP ("Move-XamlResource-SelfTest-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $temp | Out-Null

    try {
        $sampleSource = Join-Path $temp "SampleView.xaml"
        $sampleTarget = Join-Path $temp "SampleView.Resources.xaml"
        @'
<UserControl
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:local="clr-namespace:Sample">
    <UserControl.Resources>
        <Style x:Key="KeepStyle" TargetType="TextBlock" />
        <DataTemplate x:Key="MoveMe" DataType="{x:Type local:Thing}">
            <TextBlock Text="Moved" />
        </DataTemplate>
    </UserControl.Resources>
    <Grid />
</UserControl>
'@ | Set-Content -Path $sampleSource -Encoding utf8

        & $PSCommandPath -Source $sampleSource -Target $sampleTarget -Key MoveMe -NoMergeUpdate | Out-Null

        $sampleSourceText = Get-Content -Path $sampleSource -Raw
        $sampleTargetText = Get-Content -Path $sampleTarget -Raw
        [xml]$sampleSourceText | Out-Null
        [xml]$sampleTargetText | Out-Null
        Assert-Condition (-not $sampleSourceText.Contains("SampleView.Resources.xaml")) "-NoMergeUpdate modified source merge dictionaries."
        Assert-Condition $sampleTargetText.Contains('x:Key="MoveMe"') "Moved resource was not written to target."
        Assert-Condition $sampleTargetText.Contains('xmlns:local="clr-namespace:Sample"') "Required xmlns was not copied to target."

        $mergeSource = Join-Path $temp "MergeView.xaml"
        $mergeTarget = Join-Path $temp "MergeView.Resources.xaml"
        @'
<UserControl
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <UserControl.Resources>
        <Style x:Key="MoveStyle" TargetType="TextBlock" />
    </UserControl.Resources>
    <Grid />
</UserControl>
'@ | Set-Content -Path $mergeSource -Encoding utf8

        & $PSCommandPath -Source $mergeSource -Target $mergeTarget -Key MoveStyle | Out-Null

        $mergeSourceText = Get-Content -Path $mergeSource -Raw
        $mergeTargetText = Get-Content -Path $mergeTarget -Raw
        [xml]$mergeSourceText | Out-Null
        [xml]$mergeTargetText | Out-Null
        Assert-Condition $mergeSourceText.Contains("MergeView.Resources.xaml") "Merged dictionary reference was not added."
        Assert-Condition $mergeTargetText.Contains('x:Key="MoveStyle"') "Moved style was not written to target."

        $blockedCases = @(
            @{
                Name = "EventAttribute"
                Resource = '<DataTemplate x:Key="Bad"><Button Click="OnClick" /></DataTemplate>'
            },
            @{
                Name = "EventSetter"
                Resource = '<Style x:Key="Bad" TargetType="Button"><EventSetter Event="Click" Handler="OnClick" /></Style>'
            },
            @{
                Name = "NamedElement"
                Resource = '<DataTemplate x:Key="Bad"><TextBlock x:Name="Named" /></DataTemplate>'
            },
            @{
                Name = "ElementNameBinding"
                Resource = '<DataTemplate x:Key="Bad"><TextBlock Text="{Binding Text, ElementName=Named}" /></DataTemplate>'
            }
        )

        foreach ($case in $blockedCases) {
            $blockedSource = Join-Path $temp "$($case.Name).xaml"
            $blockedTarget = Join-Path $temp "$($case.Name).Resources.xaml"
@"
<UserControl xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <UserControl.Resources>
        $($case.Resource)
    </UserControl.Resources>
</UserControl>
"@ | Set-Content -Path $blockedSource -Encoding utf8

            $blocked = $false
            try {
                & $PSCommandPath -Source $blockedSource -Target $blockedTarget -Key Bad -DryRun | Out-Null
            }
            catch {
                $blocked = $true
            }

            Assert-Condition $blocked "$($case.Name) was not blocked."
        }

        "Move-XamlResource self-test passed."
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force
        }
    }
}

if ($SelfTest) {
    Invoke-SelfTest
    return
}

if ([string]::IsNullOrWhiteSpace($Source)) {
    throw "Source is required unless -SelfTest is specified."
}

if ([string]::IsNullOrWhiteSpace($Target)) {
    throw "Target is required unless -SelfTest is specified."
}

if ($null -eq $Key -or $Key.Count -eq 0) {
    throw "Key is required unless -SelfTest is specified."
}

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$targetPath = if (Test-Path -LiteralPath $Target) {
    (Resolve-Path -LiteralPath $Target).Path
}
else {
    [System.IO.Path]::GetFullPath($Target)
}

$sourceText = Read-TextFile $sourcePath
Assert-WellFormedXml $sourceText "Source"

$sourceXmlns = Get-XmlnsMap $sourceText
$movedBlocks = @()

foreach ($resourceKey in $Key) {
    $block = Find-ResourceBlock $sourceText $resourceKey
    if (-not $AllowEventHandlers) {
        Assert-NoBehaviorCoupling $block.Text $resourceKey
    }

    $movedBlocks += $block.Text
    $sourceText = Remove-ResourceBlock $sourceText $block.Start $block.End
}

$targetText = if (Test-Path -LiteralPath $targetPath) {
    Read-TextFile $targetPath
}
else {
    New-ResourceDictionaryText $sourceXmlns
}

Assert-WellFormedXml $targetText "Target"

$usedPrefixes = @($movedBlocks | ForEach-Object { Get-UsedXmlnsPrefixes $_ } | Sort-Object -Unique)
$targetText = Add-MissingXmlns $targetText $sourceXmlns $usedPrefixes
$targetText = Add-ResourcesToTarget $targetText $movedBlocks

if (-not $NoMergeUpdate -and [string]::IsNullOrWhiteSpace($DictionarySource)) {
    $DictionarySource = Get-DefaultDictionarySource $sourcePath $targetPath
}

if (-not $NoMergeUpdate) {
    $sourceText = Add-MergedDictionary $sourceText $DictionarySource
}

Assert-WellFormedXml $sourceText "Updated source"
Assert-WellFormedXml $targetText "Updated target"

if ($DryRun) {
    "Would move $($Key.Count) resource(s): $($Key -join ', ')"
    "Source: $sourcePath"
    "Target: $targetPath"
    if ($NoMergeUpdate) {
        "DictionarySource: not updated because -NoMergeUpdate was specified"
    }
    else {
        "DictionarySource: $DictionarySource"
    }
    return
}

$targetDirectory = Split-Path -Parent $targetPath
if (-not [string]::IsNullOrWhiteSpace($targetDirectory) -and -not (Test-Path -LiteralPath $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}

Write-TextFile $sourcePath $sourceText
Write-TextFile $targetPath $targetText

"Moved $($Key.Count) resource(s): $($Key -join ', ')"
"Source: $sourcePath"
"Target: $targetPath"
if ($NoMergeUpdate) {
    "DictionarySource: not updated because -NoMergeUpdate was specified"
}
else {
    "DictionarySource: $DictionarySource"
}
