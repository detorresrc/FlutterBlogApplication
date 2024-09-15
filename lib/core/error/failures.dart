class Failure {
  final String message;

  Failure([this.message = 'An unexpteded error occured.']);

  @override
  String toString() => message;
}
