## 0.2.0

- Add crafts that support queueing of the requests using `RequestQueueing`.
- Abstract versions of `OauthCraft` with mixins have been added (`RefreshableOauthCraft`, `AutoRefreshingOauthCraft`, `PersistableOauthCraft`, and `QOAuthCraft`).

Additionally, the implementation of all crafts has been moved from separate files containing mixins
to the base `lib/src/craft/craft.dart` file.

## 0.1.0

Add basic crafts with `Refreshable`, `AutoRefreshing`, and `Persistable` functionality, and
a combination of these.

## 0.0.0

Pub.dev package reservation
