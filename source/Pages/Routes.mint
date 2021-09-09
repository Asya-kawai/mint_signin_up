routes {
  /sign-in {
    sequence {
      Application.initialize()

      case (Application.user) {
        UserStatus::LoggedIn(user) => Window.navigate("/")

        UserStatus::LoggedOut =>
          parallel {
            Application.setPage(Page::SignIn)
            Forms.SignIn.reset()
          }
      }
    }
  }

  /sign-up {
    sequence {
      Application.initialize()

      case (Application.user) {
        UserStatus::LoggedOut => Application.setPage(Page::SignUp)
        UserStatus::LoggedIn(user) => Window.navigate("/")
      }
    }
  }
}