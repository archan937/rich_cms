require "database_cleaner"
DatabaseCleaner.strategy = :truncation, {:only => %w(cms_contents)}

AUTHS = %w(authlogic devise)