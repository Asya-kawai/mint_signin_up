enum UserStatus {
  LoggedIn(User)
  LoggedOut
}

enum Page {
  Initial
  SignIn
  SignUp
}

store Application {
  state user : UserStatus = UserStatus::LoggedOut
  state page : Page = Page::Initial

  fun initialize : Promise(Never, void) {
    sequence {
      Http.abortAll()

      try {
        data =
          Storage.Local.get("user")
        object =
          Json.parse(data)
          |> Maybe.toResult("")

        currentUser = decode object as User
        next { user = UserStatus::LoggedIn(currentUser) }
      } catch Storage.Error => error {
        next { user = UserStatus::LoggedOut }
      } catch Object.Error => error {
        // Cloud not decode!
        next { user = UserStatus::LoggedOut }
      } catch String => error {
        // Invalid JSON!
        next { user = UserStatus::LoggedOut }
      }
    }
  }

  fun setPage (page : Page) : Promise(Never, Void) {
    next { page = page }
  }

  fun initializeWithPage (page : Page) : Promise(Never, Void) {
    sequence {
      setPage(page)
      initialize()
    }
  }

  // ---
  fun resetStores : Promise(Never, Void) {
    /* TODO: implement it. */
    parallel {
      next {}
    }
  }

  fun login (user : User) : Promise(Never, Void) {
    sequence {
      Storage.Local.set("user", Json.stringify(encode user))
      resetStores()
      next { user = UserStatus::LoggedIn(user) }
      Window.navigate("/")
    } catch Storage.Error => error {
      Promise.never()
    }
  }

  fun logout : Promise(Never, Void) {
    sequence {
      Storage.Local.remove("user")
      resetStores()
      next { user = UserStatus::LoggedOut }
      Window.navigate("/")
    } catch Storage.Error => error {
      Promise.never()
    }
  }
}