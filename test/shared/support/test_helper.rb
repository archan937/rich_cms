require "database_cleaner"
DatabaseCleaner.strategy = :truncation

AUTHS = %w(authlogic devise)