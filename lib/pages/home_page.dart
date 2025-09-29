import 'package:flutter/material.dart';
import 'add_contact_page.dart';
import 'categories_screen.dart';
import '../db/db.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DbHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allContacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategId;

  final Color primaryColor = Color(0xFF263A96);

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadCategories();
    _searchController.addListener(_filterItems);
  }

  // ------------------ Database Methods ------------------
  void _loadContacts() async {
    final data = await dbHelper.getContacts();
    setState(() {
      _allContacts = data;
      _filteredContacts = data;
    });
  }

  void _loadCategories() async {
    final data = await dbHelper.getCategs();
    setState(() {
      _categories = data;
    });
  }

  void _deleteContact(int id) async {
    await dbHelper.deleteContact(id);
    _loadContacts();
  }

  // ------------------ Filtering ------------------
  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final fname = contact['firstname']?.toString().toLowerCase() ?? '';
        final lname = contact['lastname']?.toString().toLowerCase() ?? '';
        final categ = contact['categ_name']?.toString().toLowerCase() ?? '';
        final phone = contact['phone']?.toString().toLowerCase() ?? '';

        final matchesSearch =
            fname.contains(query) ||
            lname.contains(query) ||
            categ.contains(query) ||
            phone.contains(query);

        final matchesCategory =
            _selectedCategId == null || contact['categ_id'] == _selectedCategId;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // ------------------ Widgets ------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: Text("All"),
            selected: _selectedCategId == null,
            selectedColor: primaryColor.withOpacity(0.2),
            labelStyle: TextStyle(
              color: _selectedCategId == null ? primaryColor : Colors.black,
            ),
            onSelected: (_) {
              setState(() => _selectedCategId = null);
              _filterItems();
            },
          ),
          ..._categories.map((categ) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(categ['categ_name']),
                selected: _selectedCategId == categ['categ_id'],
                selectedColor: primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _selectedCategId == categ['categ_id']
                      ? primaryColor
                      : Colors.black,
                ),
                onSelected: (_) {
                  setState(() => _selectedCategId = categ['categ_id']);
                  _filterItems();
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search by name, phone, or category",
        prefixIcon: Icon(Icons.search, color: primaryColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 28,
          child: Text(
            "${contact['firstname'][0]}${contact['lastname'][0]}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: primaryColor,
        ),
        title: Text(
          "${contact['firstname']} ${contact['lastname']}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact['phone'] != null)
              Text(
                "📞 ${contact['phone']}",
                style: TextStyle(color: Colors.black87),
              ),
            Text(
              "📂 ${contact['categ_name'] ?? 'No Category'}",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddContactPage(contact: contact),
                  ),
                ).then((_) {
                  _loadContacts();
                  _filterItems();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Delete Contact"),
                    content: Text(
                      "Are you sure you want to delete this contact?",
                    ),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      TextButton(
                        child: Text("Delete"),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteContact(contact['contact_id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList() {
    if (_filteredContacts.isEmpty)
      return Center(child: Text("No contacts found"));

    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) =>
          _buildContactCard(_filteredContacts[index]),
    );
  }

  // ------------------ Build Scaffold ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildCategoryChips(),
            SizedBox(height: 10),
            _buildSearchBar(),
            SizedBox(height: 12),
            Expanded(child: _buildContactList()),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.category, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              label: Text(
                'Manage Categories',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()),
                ).then((_) => _loadCategories());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactPage()),
          ).then((_) {
            _loadContacts();
            _filterItems();
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
