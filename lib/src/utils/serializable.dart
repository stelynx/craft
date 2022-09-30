import '../request.dart';
import 'typedefs.dart';

/// Every [Request] body must inherit from [Serializable] in order to be able to
/// convert it [toJson] for sending the request and for storing it locally.
abstract class Serializable {
  /// Converts `this` to json representation.
  Json toJson();
}
