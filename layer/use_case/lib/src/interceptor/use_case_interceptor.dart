abstract class UseCaseInterceptor {
  void onCall<Param>(String tag, Param param);

  void onSuccess<Output>(String tag, Output result);

  void onError(String tag, Object error, StackTrace? stackTrace);
}
