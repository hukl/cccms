# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_cccms_session',
  :secret => 'e7eefb3fd335bc0aa3261072aab9ac8ce0ad90a8500bc0d94b0a378830aedcfa3d39bf640de4ab4445b1348b28a1a5f039fd05d0d67a54ff0c10309301d074c6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
