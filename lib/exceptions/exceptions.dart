class TExceptions implements Exception {

  final String message;

  const TExceptions([this.message = 'An unknown exception occurred.']);

  factory TExceptions.fromCode(String code) {
    switch (code) {
      case 'weak-password' :
        return const TExceptions('Please enter a stronger password');
      case 'invalid-email' :
        return const TExceptions('Email is not valid or is badly formatted.');
      case 'email-already-in-use' :
        return const TExceptions('Email already exists');
      case 'operation-not-allowed' :
        return const TExceptions('The provided sign-in provider is disabled for your Firebase project.');
      case 'user-disabled' :
        return const TExceptions('This user has been disabled. Please contact support for help.');
      case 'user-not-found' :
        return const TExceptions('Invalid details. Please create an account.');
      case 'wrong-password' :
        return const TExceptions('Incorrect password. Please try again.');
      case 'too-many-requests' :
        return const TExceptions('Too many requests. Service temporarily blocked.');
      case 'invalid-argument' :
        return const TExceptions('An invalid argument was provided to an Authentication method.');
      case 'invalid-password' :
        return const TExceptions('Incorrect password. Please try again.');
      case 'invalid-phone-number' :
        return const TExceptions('The provided phone number is invalid.');
      case 'session-cookie-expired' :
        return const TExceptions('The provided Firebase session cookie is expired.');
      case 'uid_already-exists' :
        return const TExceptions('The provided uid is already in use by an existing user.');
      default:
        return const TExceptions();
    }
  }
}