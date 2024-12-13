import 'package:flutter/material.dart';
import '../services/client.dart';
import '../protos/compte_service.pb.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Compte> comptes = [];
  TypeCompte? selectedType;

  @override
  void initState() {
    super.initState();
    fetchComptes();
  }

  Future<void> fetchComptes() async {
    final client = GrpcClient().client;
    try {
      final response = await client.allComptes(GetAllComptesRequest());
      setState(() {
        comptes = response.comptes;
      });
    } catch (e) {
      print('Error fetching comptes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching comptes.')),
      );
    }
  }

  Future<void> showTotalSoldeDialog(BuildContext context) async {
    final client = GrpcClient().client;
    try {
      final response = await client.totalSolde(GetTotalSoldeRequest());
      final stats = response.stats;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Total Solde Stats',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Count: ${stats.count}\nSum: ${stats.sum}\nAverage: ${stats.average}',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error fetching total solde: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching total solde.')),
      );
    }
  }

  Future<void> showSaveCompteForm(BuildContext context) async {
    final TextEditingController soldeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.blue.shade50,
          title: const Text(
            'Add New Compte',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 350, // Increased width for better form spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: soldeController,
                  decoration: InputDecoration(
                    labelText: 'Solde',
                    labelStyle: TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account Type:',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButton<TypeCompte>(
                    value: selectedType,
                    onChanged: (TypeCompte? newValue) {
                      setState(() {
                        selectedType = newValue;
                      });
                    },
                    items: TypeCompte.values.map<DropdownMenuItem<TypeCompte>>(
                      (TypeCompte value) {
                        return DropdownMenuItem<TypeCompte>(
                          value: value,
                          child: Text(
                            value == TypeCompte.COURANT ? 'EPARGNE' : 'COURRANT',
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                    ).toList(),
                    hint: const Text('Select Type', style: TextStyle(color: Colors.black)),
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final solde = double.tryParse(soldeController.text);

                if (solde != null && selectedType != null) {
                  final compteRequest = CompteRequest(
                    solde: solde,
                    dateCreation: DateTime.now().toIso8601String(),
                    type: selectedType!,
                  );

                  final client = GrpcClient().client;
                  await client.saveCompte(SaveCompteRequest(compte: compteRequest));
                  fetchComptes();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid inputs! Check solde and type.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> searchCompteById(BuildContext context) async {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('Search Compte', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: 'Enter Compte ID',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.green),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = int.tryParse(idController.text);
              if (id != null) {
                try {
                  final client = GrpcClient().client;
                  final response = await client.compteById(GetCompteByIdRequest(id: id));
                  final compte = response.compte;
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: const Text('Compte Details', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      content: Text(
                        'ID: ${compte.id}\nSolde: ${compte.solde}\nType: ${compte.type}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close', style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  print('Error fetching compte: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compte not found.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid ID.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCompteById(int id) async {
    final client = GrpcClient().client;
    try {
      await client.deleteCompte(DeleteCompteRequest(id: id));
      setState(() {
        comptes.removeWhere((compte) => compte.id == id);
      });
    } catch (e) {
      print('Error deleting compte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting compte.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Comptes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => searchCompteById(context),
          ),
        ],
      ),
      body: comptes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: comptes.length,
              itemBuilder: (context, index) {
                final compte = comptes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Compte #${compte.id}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Solde: ${compte.solde} | Type: ${compte.type == TypeCompte.COURANT ? 'Current' : 'Savings'}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCompteById(compte.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => showSaveCompteForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
