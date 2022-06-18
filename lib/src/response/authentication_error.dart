class AuthenticationError {
  String message;

  AuthenticationError(this.message);

  @override
  String toString() {
    return 'AuthenticationError{$message}';
  }
}