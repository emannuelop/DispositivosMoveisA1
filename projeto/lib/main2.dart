import 'package:flutter/material.dart';

void main() {
  runApp(ListaComprasApp());
}

class ListaComprasApp extends StatelessWidget {
  const ListaComprasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ListaComprasScaffold());
  }
}

class FormularioComprasScaffold extends StatelessWidget {
  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerQuantidade = TextEditingController();

  FormularioComprasScaffold({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro Produto"),
        backgroundColor: Colors.blue,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controllerNome,
            decoration: InputDecoration(
              labelText: "Nome do Produto",
              hintText: "Ex: Café",
            ),
            style: TextStyle(fontSize: 24),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controllerQuantidade,
            decoration: InputDecoration(
              labelText: "Quantidade do Produto",
              hintText: "Ex: 5",
            ),
            style: TextStyle(fontSize: 24),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              String nome = controllerNome.text;
              int quantidade = int.parse(controllerQuantidade.text);
              Produto produto = Produto(nome, quantidade);
              Navigator.pop(context, produto);
              print(produto);
            },
            child: Text("SALVAR"))
      ]),
    );
  }
}

class ListaComprasScaffoldState extends State<ListaComprasScaffold> {
  @override
  Widget build(BuildContext context) {
    //listaProdutos.add(Produto("Café", 5));

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        backgroundColor: Colors.blue,
      ),
      body: ListaCompras(widget.listaProdutos),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            final Future future =
                Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FormularioComprasScaffold();
            }));
            future.then((produtoRecebido) {
              setState(() {
                // Atualiza a tela com o novo produto
                widget.listaProdutos.add(produtoRecebido);
              });
              print("Produto Recebido $produtoRecebido");
            });
          },
          child: Icon(Icons.add)),
    );
  }
}

class ListaComprasScaffold extends StatefulWidget {
  final List<Produto> listaProdutos = [];

  @override
  State<ListaComprasScaffold> createState() {
    return ListaComprasScaffoldState();
  }
}

class ListaCompras extends StatelessWidget {
  final List<Produto> produtos;

  ListaCompras(this.produtos);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        return ItemListaCompras(produtos[index]);
      },
    );
  }
}

class ItemListaCompras extends StatelessWidget {
  final Produto produto;

  const ItemListaCompras(this.produto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(produto.nome),
        subtitle: Text(produto.quantidade.toString()),
        leading: Icon(Icons.coffee),
      ),
    );
  }
}

class Produto {
  String nome;
  int quantidade;

  Produto(this.nome, this.quantidade);

  @override
  String toString() {
    return "Produto: $nome, Quantidade: $quantidade";
  }
}
