# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cccms_session',
  :secret      => 'b50f62033369e6039f2ece511f83f10f70301024709e189ab28d42379a26b7bfd0739fb83d89b6b76dba350569e5b9d83ee4abedbd9da468deea963512e4102b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
