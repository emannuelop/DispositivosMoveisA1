import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(UserApp());
}

class UserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListaUsuariosScaffold(),
    );
  }
}

class Usuario {
  String id;
  String nome;
  String login;
  String senha;
  String pokemonFavorito;
  String imagemUrl;

  Usuario(this.id, this.nome, this.login, this.senha, this.pokemonFavorito, this.imagemUrl);

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      json['id'].toString(),
      json['nome'],
      json['login'],
      json['senha'],
      json['pokemonFavorito'],
      json['imagemUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'login': login,
      'senha': senha,
      'pokemonFavorito': pokemonFavorito,
      'imagemUrl': imagemUrl,
    };
  }

  @override
  String toString() {
    return "Usuário: $nome, Login: $login, Pokémon Favorito: $pokemonFavorito";
  }
}

class ListaUsuariosScaffold extends StatefulWidget {
  @override
  _ListaUsuariosScaffoldState createState() => _ListaUsuariosScaffoldState();
}

class _ListaUsuariosScaffoldState extends State<ListaUsuariosScaffold> {
  List<Usuario> usuarios = [];
  final String apiUrl = "https://67f6f5ef42d6c71cca63bbc9.mockapi.io/api/v1/usuario";

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        usuarios = data.map((json) => Usuario.fromJson(json)).toList();
      });
    }
  }

  Future<void> adicionarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 201) {
      final novoUsuario = Usuario.fromJson(json.decode(response.body));
      setState(() {
        usuarios.add(novoUsuario);
      });
    }
  }

  Future<void> editarUsuario(int index, Usuario usuario) async {
    print('Editando usuário com ID: ${usuario.id}');
    final response = await http.put(
      Uri.parse('$apiUrl/${usuario.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(usuario.toJson()),
    );

    print('Status: ${response.statusCode}');
    print('Resposta: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        usuarios[index] = usuario;
      });
    } else {
      print('Erro ao editar: ${response.statusCode}');
    }
  }

  Future<void> excluirUsuario(int index) async {
    final usuario = usuarios[index];
    final response = await http.delete(Uri.parse('$apiUrl/${usuario.id}'));

    if (response.statusCode == 200) {
      setState(() {
        usuarios.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Usuários"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: usuarios[index].imagemUrl.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(usuarios[index].imagemUrl),
              )
                  : Icon(Icons.person),
              title: Text(usuarios[index].nome),
              subtitle: Text('Login: ${usuarios[index].login}\nPokémon: ${usuarios[index].pokemonFavorito}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () async {
                      final usuarioAtualizado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormularioUsuarioScaffold(usuario: usuarios[index]),
                        ),
                      );
                      if (usuarioAtualizado != null && usuarioAtualizado.id.isNotEmpty) {
                        editarUsuario(index, usuarioAtualizado);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => excluirUsuario(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final usuarioNovo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormularioUsuarioScaffold(),
            ),
          );
          if (usuarioNovo != null) {
            adicionarUsuario(usuarioNovo);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FormularioUsuarioScaffold extends StatefulWidget {
  final Usuario? usuario;

  FormularioUsuarioScaffold({this.usuario});

  @override
  _FormularioUsuarioScaffoldState createState() => _FormularioUsuarioScaffoldState();
}

class _FormularioUsuarioScaffoldState extends State<FormularioUsuarioScaffold> {
  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerLogin = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  final TextEditingController controllerPokemon = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      controllerNome.text = widget.usuario!.nome;
      controllerLogin.text = widget.usuario!.login;
      controllerSenha.text = widget.usuario!.senha;
      controllerPokemon.text = widget.usuario!.pokemonFavorito;
    }
  }

  Future<String> buscarImagemPokemon(String nomePokemon) async {
    try {
      final url = 'https://pokeapi.co/api/v2/pokemon/${nomePokemon.toLowerCase()}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['sprites']['front_default'] ?? imagemPadrao();
      } else {
        return imagemPadrao();
      }
    } catch (e) {
      return imagemPadrao();
    }
  }

  String imagemPadrao() {
    return 'https://avatars.githubusercontent.com/u/583231?v=4';
  }

  void salvarUsuario() async {
    String nome = controllerNome.text;
    String login = controllerLogin.text;
    String senha = controllerSenha.text;
    String pokemon = controllerPokemon.text;

    if (nome.isEmpty || login.isEmpty || senha.isEmpty || pokemon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Preencha todos os campos."),
      ));
      return;
    }

    String imagemUrl = await buscarImagemPokemon(pokemon);

    final novoUsuario = Usuario(
      widget.usuario?.id ?? '', // Mantém o ID se for edição
      nome,
      login,
      senha,
      pokemon,
      imagemUrl,
    );

    Navigator.pop(context, novoUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario != null ? "Editar Usuário" : "Cadastrar Usuário"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controllerNome,
                decoration: InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: controllerLogin,
                decoration: InputDecoration(labelText: "Login"),
              ),
              TextField(
                controller: controllerSenha,
                decoration: InputDecoration(labelText: "Senha"),
                obscureText: true,
              ),
              TextField(
                controller: controllerPokemon,
                decoration: InputDecoration(labelText: "Pokémon Favorito"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: salvarUsuario,
                child: Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
