import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:notes/entities/user_entity.dart';
import 'package:notes/models/user_model.dart';
import 'package:notes/repositories/repositories.dart';

import '../../config/paths.dart';

class AuthRepository extends BaseAuthRepository {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  AuthRepository({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  void dispose() {}

  @override
  Future<User?> getCurrentUser() async {
    final currentUser = await _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return await _firebaseUserToUser(currentUser);
  }

  @override
  Future<bool> isAnonymous() async {
    final currentUser = await _firebaseAuth.currentUser;
    return currentUser!.isAnonymous;
  }

  Future<User> _firebaseUserToUser(auth.User user) async {
    DocumentSnapshot userDoc =
        await _firestore.collection(Paths.users).doc(user.uid).get();
    if (userDoc.exists) {
      User user = User.fromEntity(UserEntity.fromSnapshot(userDoc));
      return user;
    }
    return User(id: user.uid, email: '');
  }

  @override
  Future<User> loginAnonymously() async {
    final authresult = await _firebaseAuth.signInAnonymously();
    return await _firebaseUserToUser(authresult.user!);
  }

  @override
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return await _firebaseUserToUser(authResult.user!);
  }

  @override
  Future<User> logout() async {
    await _firebaseAuth.signOut();
    return await loginAnonymously();
  }

  @override
  Future<User> signupWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // The goal here is to link a newly created user to an anonymous account
    final currentUser = _firebaseAuth.currentUser;
    final authCredential =
        auth.EmailAuthProvider.credential(email: email, password: password);
    final authResult = await currentUser?.linkWithCredential(authCredential);
    final user = await _firebaseUserToUser(authResult!.user!);
    _firestore
        .collection(Paths.users)
        .doc(user.id)
        .set(user.toEntity().toDocument());
    return user;
  }
}
