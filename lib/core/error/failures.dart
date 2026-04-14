abstract class Failure {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'No Internet Connection']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}
