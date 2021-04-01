# This file just contains some example maintenance code and shouldn't be run as is

# This OAuth workflow seems to work to get a valid OAuth 2 token from Keycloak.
# However, it's then still a manual job to give the resulting user the right permissions in ATLAS.
app <- oauth_app("kees-r-client","kees-r-client",secret=secret)
baseUrl <- "https://pioneer.thehyve.net/auth/realms/pioneer/protocol/openid-connect"
endpoint <- oauth_endpoint(authorize = "auth", access = "token",base_url = baseUrl)
token <- oauth2.0_token(endpoint, app, use_oob = TRUE, oob_value=NULL, client_credentials = TRUE)

# See Download-cohorts-from-WebAPI.R for an alternative way to authenticate

