import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:mockito/mockito.dart';

class MockDatabases extends Mock implements Databases {}

class MockDocumentList extends Mock implements DocumentList {}

class MockDocument extends Mock implements Document {
  @override
  final Map<String, dynamic> data;
  @override
  final String $id;

  MockDocument({required this.data, required String id}) : $id = id;
}
