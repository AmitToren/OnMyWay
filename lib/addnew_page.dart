//import 'location_picker.dart';
import 'placepicker.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';


class AddNewPage extends StatefulWidget {
  final List<globals.SavedContact> contactsSaved;
  AddNewPage(this.contactsSaved);

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
          _filteredContacts = _contacts
              .where((c) => c.displayName
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
              .toList();
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
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        _appBarTitle = TextField(
            autofocus: true,
            controller: _filter,
            style: TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white,),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white, fontSize: 16)
            )
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text("Add Location to Contact");
        _filteredContacts = _contacts;
        _filter.clear();
      }
    });
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
    contacts = filterOutSavedContacts(contacts);
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }
  
  filterOutSavedContacts(contacts) {
    return contacts.where((contact) => widget.contactsSaved.where((saved) => saved.identifier == contact.identifier).length == 0);
  }

  contactSelected(Contact c) async {
    globals.SavedContact retContact = new globals.SavedContact(c.displayName, c.phones.first.value, c.identifier);

    /*final locationPicked = await pickLocation();
    retContact.setLocation(locationPicked);*/

    var pickedLocationJson = await pickLocation();
    retContact.setLocation(pickedLocationJson["location"]);
    retContact.setAddress(pickedLocationJson["address"]);
    Navigator.pop(context, retContact);
  }

  pickLocation() async {
    /*final locationPicked = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => LocationPickerPage()));
    return locationPicked;*/
    final addressPicked = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => LocationPickerPage()));

    return addressPicked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                  return Container(
                    child: ListTile(
                      onTap: () async {
                        print("Selected Contact: Name: " + c.displayName);
                        print("Selected Contact: Phone: " + c.phones.first.toString());
                        await contactSelected(c);
                      },
                      leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(c.displayName.length > 1
                              ? c.displayName?.substring(0, 2)
                              : "")),
                      title: Text(c.displayName ?? ""),
                    ),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black26))),
                  );
                },
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
