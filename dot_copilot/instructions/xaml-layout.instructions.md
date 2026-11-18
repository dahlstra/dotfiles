---
description: "XAML and WPF mechanics: platform identification, Grid sizing and placement, resources, bindings, scrolling, third-party styling, rendered validation, and build proportionality."
applyTo: "**/*.xaml"
---

# XAML layout editing rules

For material layout changes, load `ui-design` when available for the full layout contract, preservation, accessibility, and design guidance. These instructions remain usable without that skill.

Before editing, state the intended sizing, alignment, overflow behavior, and relevant invariants. Reason through supported sizes, preserve keyboard reachability and legible states, and distinguish observed rendered results from source-based inference. Ask when missing direction would materially change the layout or behavior.

Tool paths below are examples for the current setup (`$HOME\.copilot\tools`). In another agent environment, use its equivalent local tools when available; these tools are not required dependencies.

## Identify the XAML platform

Before applying framework-specific rules, identify the framework from the containing project rather than assuming that all XAML behaves like WPF. Sections marked WPF apply only to WPF projects.

Strong indicators include:

- WPF: `<UseWPF>true</UseWPF>` or `Microsoft.NET.Sdk.WindowsDesktop`
- .NET MAUI: `<UseMaui>true</UseMaui>`
- WinUI: `Microsoft.WindowsAppSDK`
- Xamarin.Forms: Xamarin.Forms package references and Xamarin Android/iOS projects
- Avalonia: Avalonia package references

If the platform is uncertain, inspect the containing project file before making platform-specific recommendations. Do not transfer WPF sizing, resource, binding, or templating behavior to another XAML framework without confirming that it applies.

## WPF: Treat Grid sizing as behavior, not styling

Do not swap between `Auto`, `*`, fixed widths, `MinWidth`, `MaxWidth`, or `SharedSizeGroup` casually.

Rules:

- Use `SharedSizeGroup` when header/body columns must remain aligned.
- Do not remove shared sizing to gain spacing; add explicit spacer columns instead.
- Use bounded spacer columns for flexible gaps.
- Put flexible leftover space where the design intends it, not wherever the grid happens to allow it.
- For progress bars or other flexible content with trailing dynamic text, use an internal grid with a star-sized content column, an explicit spacer column, and an `Auto` text column. Do not let changing label width alter the flexible content's intended width.
- Avoid viewport-width bindings unless the parent layout cannot provide stretch behavior correctly.

## WPF: Organize view-local resources without hiding behavior

If `UserControl.Resources` grows large enough to obscure the actual view structure, move view-specific presentation resources into a sibling `*.Resources.xaml` dictionary and merge it from the view.

Resource ownership:

- global visual primitives and design tokens belong in theme/application dictionaries
- one-view templates and styles belong in the view folder, usually in a sibling `*.Resources.xaml`
- behavior-coupled templates should stay near the code-behind or be extracted into a dedicated control

Prefer moving:

- styles
- control templates
- data templates
- spacing tokens
- converters used only by the moved templates

Keep the main view XAML focused on the UI hierarchy: page shell, sections, cards, headers, and item hosts.

Do not move templates with code-behind event handlers into loose dictionaries unless the event handler behavior is explicitly preserved and validated.

Do not extract repeated XAML just because it repeats. Prefer explicit duplicated form markup when it keeps layout behavior obvious.

Do not introduce attached-property layout systems, generic field builders, custom panels, or other layout abstractions unless explicitly requested.

Keep required converters, spacing resources, and local styles in the same dictionary as the templates that use them unless they are already global application resources.

Use `StaticResource` for stable local resources; use `DynamicResource` for theme-dependent brushes, colors, and tokens.

Before adding custom chrome, inline font stacks, one-off text sizes, or one-off surface brushes, search existing application primitives and styles first (for example gallery examples, banners, cards, badges, progress styles, and shared text styles). Reuse existing primitives unless they cannot represent the requested UX.

When choosing brushes for new surfaces or status areas, check both light and dark theme resource values. Prefer semantic primitives or semantic brushes for semantic UI states such as info, warning, error, active monitoring, and progress feedback.

After splitting or moving resource dictionaries, validate that the consuming view still builds and that moved resources resolve from the expected scope.

When moving keyed XAML resources between files, prefer `$HOME\.copilot\tools\Move-XamlResource.ps1` when available; read its `Get-Help` first. If the tool reports event handlers, unresolved namespaces, or unsafe resource placement, stop and resolve the issue explicitly rather than bypassing its refusal. If unavailable, inspect key collisions, namespace mappings, and behavior coupling before moving resources, then validate the consuming view's build and resource resolution.

## WPF: Be explicit about Grid placement

For non-first-child elements in a `Grid`, set `Grid.Row` and/or `Grid.Column` explicitly, including `0`, when the intended placement is not visually obvious or tooling such as ReSharper expects it.

## WPF: Layout-affecting animation

`LayoutTransform` and animating `Width`, `Height`, `MinWidth`, or `MaxWidth` cause reflow; prefer `RenderTransform` when the animation does not need to affect surrounding layout.

## WPF: Binding modes

When a view's runtime `DataContext` is assigned in code or dependency injection, give the XAML designer explicit type information with `d:DataContext="{d:DesignInstance Type=local:ViewModelType}"`, following the project's existing namespace syntax. Ensure `d` is included in `mc:Ignorable`. Keep this design-time-only; do not add a parameterless constructor, sample-data service, or runtime `DataContext` solely to silence designer "unknown data context" diagnostics.

When binding to read-only viewmodel properties on controls or dependency properties that may default to two-way binding, specify `Mode=OneWay` explicitly.

For changed bindings or templates, check available binding diagnostics rather than assuming a successful build proves that bindings resolve at runtime. Surface binding failures; do not hide them with silent fallbacks.

## WPF: Preserve scrolling and virtualization

When changing item layouts:

- do not place a virtualized items control inside an unconstrained `ScrollViewer`
- do not replace a virtualizing items panel without an explicit reason
- avoid nested scrolling regions unless their interaction is intentional
- preserve finite measurement constraints where stretching, scrolling, or virtualization depends on them

## WPF: Third-party control styling

For WPF/XAML styling bugs involving third-party controls, do not start with retemplating.

Investigation order:

1. Identify the visual state involved: normal, hover, focus, disabled, read-only, selected, invalid, or pressed.
2. Check vendor palette/theme APIs and documented theme resources for that state.
3. Check existing application theme bridge code that maps app brushes into vendor theme slots.
4. Check whether a style setter, inherited property, or attached theme-helper property controls the target visual.
5. Only inspect or retemplate control templates after proving the behavior is not controlled by a theme slot, resource key, inherited property, or attached helper.

For Telerik controls, `$HOME\.copilot\tools\Dump-TelerikThemeState.ps1` prints the effective Fluent palette values (step 2) and the `ThemeHelper` attached properties (step 4); read its `Get-Help` first.

When a style setter fails, stop and reassess which layer owns the visual before adding another setter.

## WPF: Rendered validation

When isolated native rendering is proportionate and an existing build is available, prefer `$HOME\.copilot\tools\Render-WpfFixture.ps1` over writing another rendering harness. Read its `Get-Help` documentation and use a fresh PowerShell 7 process with `-STA`. Supply a trusted fixture containing feature-specific data, resources, states, and layout assertions; keep those details out of the tool. Inspect its PNG output and assertion/binding results. The renderer hosts an adorner layer so actual validation chrome can render. Explicit scenario options belong in `-FixtureParameters @{ ... }`, not environment variables. Hashtable arguments require invocation through `pwsh -Command`, not `pwsh -File`.

Use the renderer's opt-in `-CaptureOnFailure` when diagnostic artifacts would help investigate a failed render. Its `.failure.png` and `.failure.json` outputs are failure evidence, not passing validation; the command still fails. Failures before a native visual is available cannot produce a screenshot.

Before inventing application resource/bootstrap setup, look for existing agent-local fixtures in `$HOME\.copilot\tools\<RepositoryName>`. Read each script's comment-based help with `Get-Help <path> -Full`. Use its documented smoke check and conservative minimum dimensions; renderer/bootstrap `-SelfTest` modes use disposable inputs and clean up. Keep these agent-local assets outside the repository unless the team explicitly adopts them as developer tooling.

Before editing, identify both the desired change and existing behavior to preserve; capture a baseline when practical. Inspect and assert the actual visible template parts, not only outer control properties. Check alignment/spacing, colors/contrast, wrapping, and validation adorners as relevant. Allow at most native-pixel rounding in geometry comparisons; do not relax a failed preservation assertion without an evidence-backed reason.

Use a small risk-based matrix of affected widths, themes, states, and content rather than every combination by default. Reports identify build timestamps, fixture options, native DPI, and binding/assertion results. Verify that the selected existing build reflects relevant compiled changes; source-extracted markup is not proof that the compiled view is current. State which evidence comes from compiled controls versus current source snippets and fixture-only constraints.

For scrolling items controls, make the first representative render narrow and populated enough to require scrolling. Verify repeated-row alignment, trailing content, and selection bounds against the actual content viewport and scrollbar bounds, not only the control's outer width. Inspect whether the vendor scrollbar overlays content before choosing a reservation mechanism.

Keep standalone render checks separate from unit tests. Do not add native UI tests or vendor runtime references to a unit-test project without explicit approval. Do not build or render solely because tooling exists, or treat fixture evidence as full-app command, keyboard, accessibility, hardware, high-contrast, theme-transition, or multi-DPI validation. Record remaining manual checks rather than claiming they passed.

## Build and test proportionality

Do not require rebuilding, launching, emulator startup, or external-device deployment for every layout edit.

Use a targeted build for meaningful XAML, resource, or template changes that could affect generated code or resource resolution. Do not run unit tests by default after layout-only XAML tweaks. Run targeted unit tests when the change affects viewmodel behavior, converters, commands, binding logic, public state, or non-XAML code.
