class <%= model_class_name %>Session < Authlogic::Session::Base

  authenticate_with <%= model_class_name %>
  generalize_credentials_error_messages true
  params_key "user_credentials"

end