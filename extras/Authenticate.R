app <- oauth_app("kees-r-client","kees-r-client",secret=secret)
baseUrl <- "https://pioneer.thehyve.net/auth/realms/pioneer/protocol/openid-connect"
endpoint <- oauth_endpoint(authorize = "auth", access = "token",base_url = baseUrl)
token <- oauth2.0_token(endpoint, app, use_oob = TRUE, oob_value=NULL, client_credentials = TRUE)