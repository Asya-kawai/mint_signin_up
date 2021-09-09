// What means an argument of 'a'?
enum Api.Status(a) {
  Error(Map(String, Array(String)))
  Loading
  Initial
  Ok(a)
}

record ErrorResponse {
  errors : Map(String, Array(String))
}

module Api {
  fun toStatus (status : Api.Status(a)) : Status {
    case (status) {
      Api.Status::Loading => Status::Loading
      Api.Status::Initial => Status::Initial
      Api.Status::Error => Status::Error
      Api.Status::Ok => Status::Ok
    }
  }

  fun errorStatus (key : String, value : String) : Api.Status(a) {
    Api.Status::Error(error)
  } where {
    error =
      Map.empty()
      |> Map.set(key, [value])
  }

  fun decodeErrors (body : String) : Api.Status(a) {
    try {
      object =
        Json.parse(body)
        |> Maybe.toResult("")
      errors =
        decode object as ErrorResponse
      Api.Status::Error(errors.errors)
    } catch Object.Error => error {
      errorStatus("request", "Cloud not decode the error response")
    } catch String => erorr {
      errorStatus("request", "Cloud not parse the error response.")
    }
  }

  fun send (
    decoder : Function(Object, Result(Object.Error, a)),
    rawRequest : Http.Request
  ) : Promise(Never, Api.Status(a)) {
    sequence {
      /* Try to get a token from session storage. */
      request =
        case (Application.user) {
          UserStatus::LoggedIn(user) =>
            Http.header(
              "Authorization",
              "Token" + user.token,
              rawRequest
            )
          UserStatus::LoggedOut => rawRequest
        }

      /* Get the response.
         Add or update an url field in the request tuple. */
      response =
        { request | url = "https://conduit.productionready.io/api" + request.url }
        |> Http.header("Content-Type", "application/json")
        |> Http.send()

      /* Handle response based on status. */
      case (response.status) {
        401 => errorStatus("request", "Unauthorized")
        403 => decodeErrors(response.body)
        422 => decodeErrors(response.body)
        // default
        =>
          try {
            object =
              Json.parse(response.body)
              |> Maybe.toResult("")

            data =
              decoder(object)

            Api.Status::Ok(data)
          } catch Object.Error => error {
            errorStatus("request", "Cloud not decode the response.")
          } catch String => error {
            errorStatus("request", "Cloud not parse the response.")
          }
      }
    } catch Http.ErrorResponse => error {
      errorStatus("reqeust", "Network error.")
    }
  }

  // ---
  fun errorsOf (key : String, status : Api.Status(a)) : Array(String) {
    case (status) {
      Api.Status::Error(errors) =>
        errors
        |> Map.get(key)
        |> Maybe.withDefault([])
      // default
      => []
    }
  }

  fun isLoading (status : Api.Status(a)) : Bool {
    case (status) {
      Api.Status::Loading => true
      => false
    }
  }
}