
deps:
	bundle update
	bundle install

start: deps
	- pkill -f ruby
	rake run > /dev/null 2>&1 &

