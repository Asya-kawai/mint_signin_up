component Main {
  connect Application exposing { page }

  fun render : Html {
    case (page) {
      Page::Initial => Html.empty()
      Page::SignIn => <Pages.SignIn/>
      Page::SignUp => <Pages.SignUp/>      
    }
  }
}