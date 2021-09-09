record User {
  email : String,
  token : String
}

module User {
  fun empty : User {
    {
      email = "",
      token = ""
    }
  }

  fun decode (object : Object) : Result(Object.Error, User) {
    decode object as User
  }

  fun fromResponse (object : Object) : Result(Object.Error, User) {
    with Object.Decode {
      field("user", decode, object)
    }
  }
}