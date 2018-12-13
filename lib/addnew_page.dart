import 'dart:async';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'location_picker.dart';

class AddNewPage extends StatefulWidget {
  AddNewPageState createState() => new AddNewPageState();
}

class AddNewPageState extends State<AddNewPage> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Widget _appBarTitle = Text("Add Location to Contact");
  Icon _searchIcon = Icon(Icons.search);
  Iterable<Contact> _contacts;
  Iterable<Contact> _filteredContacts;

  AddNewPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _filter.clear();
          _searchText = "";
          _filteredContacts = _contacts;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
          _filteredContacts = _contacts.where((c) => c.displayName.toLowerCase().contains(_searchText.toLowerCase())).toList();
        });
      }
    });
  }

  @override
  initState() {
    super.initState();
    refreshContacts();
  }

  searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = Text("Add Location to Contact");
        _filteredContacts = _contacts;
        _filter.clear();
      }
    });
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  contactSelected(Contact c) async {
    final locationPicked = await pickLocation();
    Navigator.pop(context, {'contact': c, 'location': locationPicked });
  }

  pickLocation() async {
    final _locationPicked = await
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            LocationPickerPage()));

    return _locationPicked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: searchPressed,
          )
        ],
      ),
      body: SafeArea(
        child: _filteredContacts != null
            ? ListView.builder(
          itemCount: _filteredContacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _filteredContacts?.elementAt(index);
            return ListTile(
              onTap: () {
                contactSelected(c);
              },
              leading: ((c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                  : CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Text(c.displayName.length > 1
                          ? c.displayName?.substring(0, 2)
                          : "")
                    )
              ),
              title: Text(c.displayName ?? ""),
            );
          },
        ) : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}