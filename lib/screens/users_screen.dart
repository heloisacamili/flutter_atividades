import 'package:atividade/services/secure_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadUsers();
  }

  Future<void> _loadToken() async {
    _authToken = await SecureStorageService.getToken();
    setState(() {});
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      // busca do Firebase
      final users = await FirebaseService.getAllUsers();
      setState(() => _users = users);
    } catch (e) {
      _showError('Erro ao carregar usuários: $e');
      // Fallback para dados demo se Firebase falhar
      _loadDemoUsers();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadDemoUsers() {
    setState(() {
      _users = [
        AppUser(
          id: 'demo1',
          name: 'João Silva (Demo)',
          email: 'joao@email.com',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
        ),
        AppUser(
          id: 'demo2',
          name: 'Maria Santos (Demo)',
          email: 'maria@email.com',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        ),
      ];
    });
  }

  Future<void> _createUser() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      _showError('Preencha todos os campos obrigatórios');
      return;
    }

    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporário
      name: _nameController.text,
      email: _emailController.text,
      createdAt: DateTime.now(),
    );

    try {
      await FirebaseService.createUser(newUser);
      _nameController.clear();
      _emailController.clear();
      _loadUsers(); // Recarrega a lista
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário salvo no Firebase!')),
      );
    } catch (e) {
      _showError('Erro ao salvar usuário: $e');
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseService.deleteUser(userId);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário excluído!')),
      );
    } catch (e) {
      _showError('Erro ao excluir usuário: $e');
    }
  }

  Future<void> _simulateLogin() async {
    final fakeToken = 'firebase_token_${DateTime.now().millisecondsSinceEpoch}';
    await SecureStorageService.saveToken(fakeToken);
    await _loadToken();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🔐 Token armazenado com Secure Storage!')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cadastrar Novo Usuário no Firebase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome Completo*',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createUser();
            },
            child: Text('Salvar no Firebase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários (Firebase Firestore)'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_authToken != null)
            IconButton(
              icon: Icon(Icons.security),
              onPressed: () => _showTokenDialog(),
              tooltip: 'Ver Token',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_authToken != null)
            Card(
              margin: EdgeInsets.all(8),
              color: Colors.green[50],
              child: ListTile(
                leading: Icon(Icons.verified_user, color: Colors.green),
                title: Text('Autenticado com Secure Storage'),
                subtitle: Text('Token seguro armazenado no dispositivo'),
                trailing: IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    await SecureStorageService.deleteAllTokens();
                    _loadToken();
                  },
                ),
              ),
            ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum usuário cadastrado',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Clique no + para adicionar um usuário',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<List<AppUser>>(
                        stream: FirebaseService.getUsersStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Erro: ${snapshot.error}'));
                          }
                          
                          final users = snapshot.hasData ? snapshot.data! : _users;
                          
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user.name[0]),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      Text(
                                        'Cadastrado: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteUser(user.id!),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_authToken == null)
            FloatingActionButton(
              onPressed: _simulateLogin,
              child: Icon(Icons.login),
              backgroundColor: Colors.orange,
              heroTag: 'login',
            ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showCreateUserDialog,
            child: Icon(Icons.person_add),
            backgroundColor: Colors.green,
            heroTag: 'add_user',
          ),
        ],
      ),
    );
  }

  void _showTokenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Token de Autenticação (Secure Storage)'),
        content: SelectableText(
          _authToken ?? 'Nenhum token encontrado',
          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}