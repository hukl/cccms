# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_cccms_session',
  :secret => '0d0439210e7fe934a0867768ba18809f2ea9c77600a5d0fa24fd6b9943ab7140a0a9832fe88880ed79e0a65e2aef61b8410ac4dc893d45859fcf5872803eb33a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
