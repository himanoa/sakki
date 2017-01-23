up:
	bundle exec rackup

db-setup:
	bundle exec ridgepole -c config/database.yml -E development -a
