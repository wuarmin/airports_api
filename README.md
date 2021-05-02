# Airports API

### Development
Run the following commands to prepare your Airports API Development Environment:
```sh
$ docker volume create airports_api_db_vol
$ docker-compose build
$ docker-compose run runner ./bin/setup
```
Start the API
```sh
$ docker-compose up --build api
```

### Testing
Run the following commands to prepare your Airports API Test Environment:
```sh
$ docker-compose build
$ docker-compose run test_runner ./bin/setup
```
Run test suite
```sh
$ docker-compose run test_runner bundle exec rspec spec
```
