class User{
  int _id;
  String _name;
  int _age;

  User(this._id, this._name, this._age);

  int get age => _age;

  set age(int value) {
    _age = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}