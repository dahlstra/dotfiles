---
name: csharp-review
description: Use when reviewing changes to C#, XAML, .NET MAUI, or Android code for correctness, reliability, and regressions. Provides language- and framework-specific bug-hunting prompts, not coding standards.
---

# C# Review

Use the general C# checks for C# changes. Apply the WPF or .NET MAUI/Android checks only when that framework is relevant. These are investigation prompts, not requirements or findings by themselves. Report only concrete defects introduced, exposed, or materially worsened by the change, grounded in repository requirements, user intent, or observable behavior.

## C# correctness checks

- Check nullable and default-value paths, including assumptions at API and deserialization boundaries.
- Check integer overflow, signed and unsigned conversions, floating-point or decimal precision, and whether calculations preserve the intended sign and units.
- Trace async operations for unobserved failures, `async void` (including async lambdas converted to `Action` or other void-returning delegates), blocking waits, lost cancellation, and ordering or race conditions.
- Check exception and cancellation paths for partial updates, inconsistent state, lost cleanup, or retries that repeat non-idempotent work.
- Check that catch blocks do not silently discard failures or report success after an operation failed.
- Check shared mutable state for synchronization and ensure locks or semaphores are released on every exit path.
- Check ownership and lifetime of disposable resources, event subscriptions, timers, callbacks, tasks, and captured object references.
- Check dependency-injection lifetimes for longer-lived services retaining shorter-lived dependencies.
- Check that equality and hash-code behavior remain consistent, especially for values used as dictionary or set keys.
- Check struct mutations for accidental changes to copies rather than the original value.
- Check LINQ deferred execution, multiple enumeration, and closures when they can change results or observe stale state.
- Check date and time assumptions for time zones, daylight-saving transitions, precision, and uniqueness where relevant.
- Check parsing and formatting for culture-sensitive behavior when data crosses a persistence, protocol, or user-input boundary.
- Check string comparisons on identifiers, keys, paths, and protocol values for an explicit, appropriate comparison mode.
- Check dictionary lookups and LINQ operators such as `First` or `Single` when the key or matching item may legitimately be absent or non-unique.
- Check changes to serialized members, enum values, or protocol representations for compatibility with persisted data and external consumers.

## WPF checks

- Apply only to WPF changes.
- Check `INotifyPropertyChanged` and collection notifications for changes, resets, replacements, and derived state that the UI observes.
- Check bindings, commands, and validation paths for stale values or state that is not propagated after the change.
- Check that UI-bound state is accessed and updated on the appropriate Dispatcher thread.
- Check event handlers, timers, subscriptions, and windows or controls for correct hookup and cleanup over their lifecycle.
- Check asynchronous UI operations for reentrancy, stale completion results, cancellation, and updates after the owning view or model is replaced.

## .NET MAUI and Android checks

- Apply only to .NET MAUI or Android changes.
- Check UI and bound collection updates for main-thread affinity.
- Check lifecycle handling across backgrounding, resume, activity recreation, and process death; verify important state is restored or safely reloaded.
- Check permission-gated features for permission checks, request results, denial, and revocation.
- Check Release-only behavior where trimming or AOT can remove types or members reached through reflection, serializers, or bindings.
- Check handler and native event cleanup, subscriptions, and page or view lifetimes across Shell navigation.
- Check navigation for duplicate or reentrant requests and query parameters for missing or invalid values.
- Check platform-specific implementations and conditional compilation for missing behavior or fallback on other target platforms.
- Check Android file paths and storage APIs for case sensitivity and scoped-storage constraints; check network operations for cleartext restrictions and connectivity changes where relevant.
- Check compiled XAML bindings use a data type consistent with the actual binding context.

Do not flag these patterns merely because they appear. Establish how the reviewed change makes a concrete execution path incorrect or unsafe.
