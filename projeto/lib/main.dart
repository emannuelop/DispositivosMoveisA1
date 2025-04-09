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
  String nome;
  String login;
  String senha;
  String pokemonFavorito;
  String imagemUrl;

  Usuario(this.nome, this.login, this.senha, this.pokemonFavorito, this.imagemUrl);

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

  void adicionarUsuario(Usuario usuario) {
    setState(() {
      usuarios.add(usuario);
    });
  }

  void editarUsuario(int index, Usuario usuario) {
    setState(() {
      usuarios[index] = usuario;
    });
  }

  void excluirUsuario(int index) {
    setState(() {
      usuarios.removeAt(index);
    });
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
                      if (usuarioAtualizado != null) {
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
    final url = 'https://pokeapi.co/api/v2/pokemon/${nomePokemon.toLowerCase()}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sprites']['front_default'] ?? '';
    } else {
      return '';
    }
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

    final novoUsuario = Usuario(nome, login, senha, pokemon, imagemUrl);
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
        child: ListView(
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
    );
  }
}
