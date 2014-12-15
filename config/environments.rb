configure :production, :development do
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/jobtions_db')

	ActiveRecord::Base.establish_connection(
		username: db.user,
		adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
		host: db.host,
		password: db.password,
		database: db.path[1..-1],
		encoding: 'utf8'
	)
end