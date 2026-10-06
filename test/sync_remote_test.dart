import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spend_wise/services/sync_remote.dart';
import 'package:spend_wise/utils/database_helper.dart';

const owner = '11111111-1111-4111-8111-111111111111';
String session(String id) {
  String part(Object data) =>
      base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
  final token =
      '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part({'sub': id, 'exp': 4102444800})}.test';
  return jsonEncode({
    'access_token': token,
    'refresh_token': 'test-refresh',
    'token_type': 'bearer',
    'expires_in': 360000000,
    'user': {
      'id': id,
      'aud': 'authenticated',
      'app_metadata': {},
      'user_metadata': {},
      'created_at': '2026-01-01T00:00:00Z',
    },
  });
}

http.Response response(Object data, [int code = 200]) => http.Response(
  jsonEncode(data),
  code,
  headers: {'content-type': 'application/json'},
);

void main() {
  late SupabaseClient client;
  late SupabaseSyncRemote remote;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) handle;
  setUp(() async {
    requests = [];
    handle = (_) async => response([]);
    client = SupabaseClient(
      'https://sync.test',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        final result = await handle(request);
        return http.Response(
          result.body,
          result.statusCode,
          headers: result.headers,
          request: request,
        );
      }),
    );
    await client.auth.setInitialSession(session(owner));
    remote = SupabaseSyncRemote(client, owner, () => true);
  });
  tearDown(() async {
    await client.dispose();
  });

  test(
    'complete account-scoped download exceeds server cap and preserves shared categories',
    () async {
      final all = List.generate(
        1201,
        (index) => {'id': index.toString().padLeft(5, '0'), 'user_id': owner},
      );
      handle = (request) async {
        expect(request.headers['accept-profile'], 'spendwise');
        final table = request.url.pathSegments.last;
        final query = request.url.queryParameters;
        if (table == 'categories') {
          expect(query['or'], '(user_id.eq.$owner,user_id.is.null)');
          return response(
            query.containsKey('id')
                ? []
                : [
                    {'id': 'shared', 'user_id': null},
                  ],
          );
        }
        expect(
          query[table == 'user_profiles' ? 'id' : 'user_id'],
          table == 'user_profiles' ? 'eq.$owner' : 'eq.$owner',
        );
        if (table == 'user_profiles') return response([]);
        final cursor = query['id']?.substring(3);
        return response(
          all
              .where(
                (row) =>
                    cursor == null ||
                    (row['id'] as String).compareTo(cursor) > 0,
              )
              .take(137)
              .toList(),
        );
      };
      final result = await remote.pull();
      expect(result['expenses'], hasLength(1201));
      expect(
        result['expenses']!.map((row) => row['id']).toSet(),
        hasLength(1201),
      );
      expect(result['categories']!.single['user_id'], null);
    },
  );

  test('insert retries preserve IDs and exclude local-only metadata', () async {
    handle = (request) async => response({'id': 'expense-id'});
    final row = <String, Object?>{
      'id': 'expense-id',
      'user_id': owner,
      'name': 'Lunch',
      'category': 'food-id',
      'amount': 20,
      'sync_status': SyncStatus.pendingInsert,
      'revision': 9,
      'delete_mode': null,
      'replacement_id': null,
    };
    await remote.push('expenses', row);
    await remote.push('expenses', row);
    for (final request in requests) {
      final body = jsonDecode(request.body) as Map;
      expect(body['id'], 'expense-id');
      expect(body['user_id'], owner);
      expect(body.containsKey('revision'), false);
      expect(body.containsKey('sync_status'), false);
      expect(body.containsKey('replacement_id'), false);
      expect(
        request.headers['prefer'],
        contains('resolution=merge-duplicates'),
      );
    }
  });

  test(
    'editing a remotely deleted expense uses PATCH and reports absence',
    () async {
      expect(
        await remote.push('expenses', {
          'id': 'gone',
          'user_id': owner,
          'sync_status': SyncStatus.pendingUpdate,
          'name': 'Edit',
          'created_at': 'original',
        }),
        false,
      );
      expect(requests.single.method, 'PATCH');
      expect(requests.single.url.queryParameters['user_id'], 'eq.$owner');
      expect(
        (jsonDecode(requests.single.body) as Map).containsKey('created_at'),
        false,
      );
    },
  );

  test(
    'category move retries reuse persisted fallback ID and scope both writes',
    () async {
      final row = <String, Object?>{
        'id': 'food',
        'user_id': owner,
        'sync_status': SyncStatus.pendingDelete,
        'delete_mode': 'move',
        'replacement_id': 'other-id',
      };
      await remote.push('categories', row);
      await remote.push('categories', row);
      expect(requests.map((request) => request.method), [
        'PATCH',
        'DELETE',
        'PATCH',
        'DELETE',
      ]);
      expect(jsonDecode(requests.first.body), {'category': 'other-id'});
      for (final request in requests) {
        expect(request.url.queryParameters['user_id'], 'eq.$owner');
      }
    },
  );

  test(
    'category permanent deletion removes dependent expenses before category',
    () async {
      await remote.push('categories', {
        'id': 'food',
        'user_id': owner,
        'sync_status': SyncStatus.pendingDelete,
        'delete_mode': 'delete',
      });
      expect(requests.map((request) => request.url.pathSegments.last), [
        'expenses',
        'categories',
      ]);
      expect(requests.every((request) => request.method == 'DELETE'), true);
    },
  );

  test('failed later page rejects the whole snapshot', () async {
    handle = (request) async {
      if (request.url.queryParameters.containsKey('id')) {
        return response({'message': 'Page failed', 'code': 'TEST'}, 400);
      }
      return response([
        {'id': 'first', 'user_id': owner},
      ]);
    };
    await expectLater(remote.pull(), throwsA(isA<PostgrestException>()));
  });

  test('account change and foreign mutations make no remote request', () async {
    await expectLater(
      remote.push('expenses', {'id': 'foreign', 'user_id': 'someone-else'}),
      throwsStateError,
    );
    await client.auth.setInitialSession(
      session('22222222-2222-4222-8222-222222222222'),
    );
    await expectLater(remote.pull(), throwsStateError);
    expect(requests, isEmpty);
  });
}
