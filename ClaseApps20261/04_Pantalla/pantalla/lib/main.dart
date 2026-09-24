import 'package:flutter/material.dart';

// import 'data/repositories/usuario_api.dart'; // implementacion con red
import 'data/repositories/usuario_memoria.dart';
import 'domain/usecases/obtener_usuarios_con_vocal.dart';
import 'presentation/pages/usuarios_screen.dart';

/// Punto de composicion: es el unico lugar que arma las dependencias
/// concretas y se las inyecta a la pantalla.
void main() {
  // Unico cambio para sustituir la fuente de datos:
  // final obtenerUsuariosConVocal = ObtenerUsuariosConVocal(UsuarioApi());
  final obtenerUsuariosConVocal = ObtenerUsuariosConVocal(UsuarioMemoria());

  runApp(MyApp(obtenerUsuariosConVocal: obtenerUsuariosConVocal));
}

class MyApp extends StatelessWidget {
  final ObtenerUsuariosConVocal obtenerUsuariosConVocal;

  const MyApp({super.key, required this.obtenerUsuariosConVocal});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: UsuariosScreen(obtenerUsuariosConVocal: obtenerUsuariosConVocal),
    );
  }
}

// =============================================================================
// VESTIGIO: version original (Parte 1), antes del refactor.
//
// Todo vivia en este mismo archivo y en la misma clase de estado:
//   - llamada HTTP           -> ahora en data/repositories/usuario_api.dart
//   - jsonDecode y mapeo     -> ahora en data/repositories/usuario_api.dart
//   - filtro por vocal       -> ahora en domain/usecases/obtener_usuarios_con_vocal.dart
//   - construccion de la UI  -> ahora en presentation/pages/usuarios_screen.dart
//
// Se conserva comentado unicamente como referencia para comparar.
// Requeria ademas: import 'dart:convert'; e import 'package:http/http.dart' as http;
// =============================================================================
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Usuarios',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const UsersScreen(),
//     );
//   }
// }
//
// /// Pantalla que hace TODO: llamada HTTP, jsonDecode, regla de negocio
// /// (filtrar los nombres que empiezan con vocal) y construccion de la UI.
// class UsersScreen extends StatefulWidget {
//   const UsersScreen({super.key});
//
//   @override
//   State<UsersScreen> createState() => _UsersScreenState();
// }
//
// class _UsersScreenState extends State<UsersScreen> {
//   // La pantalla guarda directamente los mapas crudos del JSON.
//   List<Map<String, dynamic>> _users = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }
//
//   Future<void> _loadUsers() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     try {
//       // 1. Llamada HTTP dentro de la pantalla.
//       final response = await http.get(
//         Uri.parse('https://jsonplaceholder.typicode.com/users'),
//       );
//
//       if (response.statusCode != 200) {
//         setState(() {
//           _error = 'Error HTTP ${response.statusCode}';
//           _loading = false;
//         });
//         return;
//       }
//
//       // 2. Parseo del JSON dentro de la pantalla.
//       final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
//
//       // 3. Regla de negocio dentro de la pantalla:
//       //    solo los usuarios cuyo nombre empieza con vocal.
//       final List<Map<String, dynamic>> filtered = [];
//       for (final item in decoded) {
//         final user = item as Map<String, dynamic>;
//         final name = (user['name'] as String?) ?? '';
//         if (name.isEmpty) continue;
//         final firstLetter = name[0].toLowerCase();
//         if (firstLetter == 'a' ||
//             firstLetter == 'e' ||
//             firstLetter == 'i' ||
//             firstLetter == 'o' ||
//             firstLetter == 'u') {
//           filtered.add(user);
//         }
//       }
//
//       setState(() {
//         _users = filtered;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Fallo la carga: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   // 4. Construccion de la interfaz, en el mismo archivo y la misma clase.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Usuarios con nombre que empieza en vocal'),
//         actions: [
//           IconButton(
//             onPressed: _loading ? null : _loadUsers,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Recargar',
//           ),
//         ],
//       ),
//       body: Builder(
//         builder: (context) {
//           if (_loading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (_error != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(_error!),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: _loadUsers,
//                     child: const Text('Reintentar'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (_users.isEmpty) {
//             return const Center(child: Text('No hay usuarios que cumplan el filtro'));
//           }
//
//           return ListView.separated(
//             itemCount: _users.length,
//             separatorBuilder: (_, _) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final user = _users[index];
//               final name = user['name'] as String;
//               final email = user['email'] as String? ?? '';
//               final company =
//                   (user['company'] as Map<String, dynamic>?)?['name'] as String? ?? '';
//
//               return ListTile(
//                 leading: CircleAvatar(child: Text(name[0].toUpperCase())),
//                 title: Text(name),
//                 subtitle: Text('$email\n$company'),
//                 isThreeLine: true,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
