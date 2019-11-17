import 'package:com.winwisely99.app/chat_list/bloc/data.dart';
import 'package:meta/meta.dart';
import 'package:repository/repository.dart';

import 'package:com.winwisely99.app/chat_list/chat_list.dart';
import 'package:com.winwisely99.app/vendor_plugins/vendor_plugins.dart';
import '../bloc/data.dart';
import '../services.dart';
import 'network.dart';

/// A service that offers retrieval and storage of users.
class UserService {
  UserService({@required this.network})
      : assert(network != null),
        _storage = CachedRepository<User>(
          source: _UserDownloader(network: network),
          cache: HiveRepository<User>('users'),
        ) {
    userServiceReadyCompleter.complete();
  }

  final NetworkService network;

  final Repository<User> _storage;

  Future<User> getUser(Id<User> id) => _storage.fetch(id).first;
}

class _UserDownloader extends Repository<User> {
  _UserDownloader({@required this.network})
      : assert(network != null),
        super(isFinite: false, isMutable: false);

  final NetworkService network;

  @override
  Stream<User> fetch(Id<User> id) async* {
    await networkReady;
    final Map<String, dynamic> data =
        await network.getItem(path: 'users', id: id.id);

    yield User(
      id: Id<User>(data['_id']),
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      displayName: data['displayName'],
      avatarURL: data['avatarURL'],
      conversationIds: <String>[
        for (dynamic item in data['conversationIds']) item.toString()
      ],
    );
  }
}
