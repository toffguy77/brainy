## Why

Several declared dependencies have zero imports anywhere in `lib/`, `test/` or `integration_test/`:

| Package | Imports | Why it is there |
|---------|---------|-----------------|
| `cloud_functions` | 0 | Added for YooKassa; `SubscriptionService` is a stub |
| `shared_preferences` | 0 | Superseded by Hive |
| `collection` | 0 | Unclear |
| `riverpod_annotation` | 0 | No `@riverpod` annotation exists |
| `riverpod_generator` | 0 | No `.g.dart` file is generated |
| `build_runner` | 0 | Nothing to generate |

The Riverpod codegen trio is the most misleading: `CLAUDE.md` documents `dart run build_runner build --delete-conflicting-outputs` as a standard command "after adding `@riverpod` annotations", but the project contains no annotation and no generated file. Hive adapters are written by hand precisely because the generators conflict. So the documented workflow is for tooling the project does not use — a trap for anyone following the instructions.

Unused dependencies enlarge the build, slow resolution, generate dependabot noise, and misrepresent the architecture.

## What Changes

- Dependencies with no imports are removed from `pubspec.yaml`.
- The Riverpod codegen packages are removed and `CLAUDE.md` stops documenting a build_runner workflow the project does not have.
- `flutter_secure_storage` and `device_info_plus` are re-examined: both exist to support `DeviceIdService`, whose purpose was payment identity. Whether a device id is still needed once payments are gone is a real question, not a mechanical removal.
- Each removal is verified by a clean analyze, a green test run and a successful iOS build.

## Capabilities

### New Capabilities
- `dependency-hygiene`: the standard for what may be declared as a dependency.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for dependencies. -->

## Impact

- `brainy-app/pubspec.yaml`, `pubspec.lock` — dependency removals.
- `CLAUDE.md` — the build_runner command and the Riverpod codegen claim.
- `lib/shared/services/device_id_service.dart` and `test/services/device_id_service_test.dart` — possibly deleted, pending the device-id decision.
- Build times and dependabot volume both drop.

Sequencing: run after `remove-monetization-go-free`, which makes `cloud_functions` unambiguously dead and settles the device-id question by removing the payment flow that motivated it.
