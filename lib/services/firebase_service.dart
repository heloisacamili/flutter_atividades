import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  static Future<void> createUser(AppUser user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
      
      print('Usuário ${user.name} salvo no Firebase');
    } catch (e) {
      print('Erro ao salvar usuário no Firebase: $e');
      throw e;
    }
  }

  static Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          id: doc.id,
          name: data['name'],
          email: data['email'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  static Future<List<AppUser>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(_usersCollection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser(
          id: doc.id,
          name: data['name'],
          email: data['email'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  static Stream<List<AppUser>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AppUser(
                id: doc.id,
                name: data['name'],
                email: data['email'],
                createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
              );
            }).toList());
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
      print('Usuário $userId excluído do Firebase');
    } catch (e) {
      print('Erro ao excluir usuário: $e');
      throw e;
    }
  }
}