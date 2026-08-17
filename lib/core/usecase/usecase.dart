abstract class UseCase<Return, Params> {
  Future<Return> call({Params? params});
}
