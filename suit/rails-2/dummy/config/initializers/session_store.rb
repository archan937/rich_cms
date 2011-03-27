# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dummy_session',
  :secret      => 'd1c8a56dfdd85b281297eb0609660076d864c3c7f33a851ec14a80852aff00f9bf726a9fdcdb97650c45816b19a6cc1dcabbbde5d6031afe34bf5f0874bd564e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
