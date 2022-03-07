# golang-db-migrate
# migrate CLI

## Installation

### Download pre-built binary (Windows, MacOS, or Linux)

[Release Downloads](https://github.com/golang-migrate/migrate/releases)

```bash
$ curl -L https://github.com/golang-migrate/migrate/releases/download/$version/migrate.$platform-amd64.tar.gz | tar xvz
```

### MacOS

```bash
$ brew install golang-migrate
```

### Windows

Using [scoop](https://scoop.sh/)

```bash
$ scoop install migrate
```

### Linux (*.deb package)

```bash
$ curl -L https://packagecloud.io/golang-migrate/migrate/gpgkey | apt-key add -
$ echo "deb https://packagecloud.io/golang-migrate/migrate/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/migrate.list
$ apt-get update
$ apt-get install -y migrate
```

### With Go toolchain

#### Versioned

```bash
$ go get -u -d github.com/golang-migrate/migrate/cmd/migrate
$ cd $GOPATH/src/github.com/golang-migrate/migrate/cmd/migrate
$ git checkout $TAG  # e.g. v4.1.0
$ # Go 1.15 and below
$ go build -tags 'postgres' -ldflags="-X main.Version=$(git describe --tags)" -o $GOPATH/bin/migrate $GOPATH/src/github.com/golang-migrate/migrate/cmd/migrate
$ # Go 1.16+
$ go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@$TAG
```

#### Unversioned

```bash
$ # Go 1.15 and below
$ go get -tags 'postgres' -u github.com/golang-migrate/migrate/cmd/migrate
$ # Go 1.16+
$ go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

#### Notes

1. Requires a version of Go that [supports modules](https://golang.org/cmd/go/#hdr-Preliminary_module_support). e.g. Go 1.11+
1. These examples build the cli which will only work with postgres.  In order
to build the cli for use with other databases, replace the `postgres` build tag
with the appropriate database tag(s) for the databases desired.  The tags
correspond to the names of the sub-packages underneath the
[`database`](../database) package.
1. Similarly to the database build tags, if you need to support other sources, use the appropriate build tag(s).
1. Support for build constraints will be removed in the future: https://github.com/golang-migrate/migrate/issues/60
1. For versions of Go 1.15 and lower, [make sure](https://github.com/golang-migrate/migrate/pull/257#issuecomment-705249902) you're not installing the `migrate` CLI from a module. e.g. there should not be any `go.mod` files in your current directory or any directory from your current directory to the root

## Usage

```bash
$ migrate -help
Usage: migrate OPTIONS COMMAND [arg...]
       migrate [ -version | -help ]

Options:
  -source          Location of the migrations (driver://url)
  -path            Shorthand for -source=file://path
  -database        Run migrations against this database (driver://url)
  -prefetch N      Number of migrations to load in advance before executing (default 10)
  -lock-timeout N  Allow N seconds to acquire database lock (default 15)
  -verbose         Print verbose logging
  -version         Print version
  -help            Print usage

Commands:
  create [-ext E] [-dir D] [-seq] [-digits N] [-format] NAME
               Create a set of timestamped up/down migrations titled NAME, in directory D with extension E.
               Use -seq option to generate sequential up/down migrations with N digits.
               Use -format option to specify a Go time format string.
  goto V       Migrate to version V
  up [N]       Apply all or N up migrations
  down [N]     Apply all or N down migrations
  drop         Drop everything inside database
  force V      Set version V but don't run migration (ignores dirty state)
  version      Print current migration version
```

So let's say you want to run the first two migrations

```bash
$ migrate -source file://path/to/migrations -database postgres://localhost:5432/database up 2
```

If your migrations are hosted on github

```bash
$ migrate -source github://mattes:personal-access-token@mattes/migrate_test \
    -database postgres://localhost:5432/database down 2
```

The CLI will gracefully stop at a safe point when SIGINT (ctrl+c) is received.
Send SIGKILL for immediate halt.

## Reading CLI arguments from somewhere else

### ENV variables

```bash
$ migrate -database "$MY_MIGRATE_DATABASE"
```

### JSON files

Check out https://stedolan.github.io/jq/

```bash
$ migrate -database "$(cat config.json | jq '.database')"
```

### YAML files

```bash
$ migrate -database "$(cat config/database.yml | ruby -ryaml -e "print YAML.load(STDIN.read)['database']")"
$ migrate -database "$(cat config/database.yml | python -c 'import yaml,sys;print yaml.safe_load(sys.stdin)["database"]')"
```



# PostgreSQL tutorial for beginners

## Create/configure database

For the purpose of this tutorial let's create PostgreSQL database called `example`.
Our user here is `postgres`, password `password`, and host is `localhost`.
```
psql -h localhost -U postgres -w -c "create database example;"
```
When using Migrate CLI we need to pass to database URL. Let's export it to a variable for convenience:
```
export POSTGRESQL_URL='postgres://postgres:password@localhost:5432/example?sslmode=disable'
```
`sslmode=disable` means that the connection with our database will not be encrypted. Enabling it is left as an exercise.

You can find further description of database URLs [here](README.md#database-urls).

## Create migrations
Let's create table called `users`:
```
migrate create -ext sql -dir db/migrations -seq create_users_table
```
If there were no errors, we should have two files available under `db/migrations` folder:
- 000001_create_users_table.down.sql
- 000001_create_users_table.up.sql

Note the `sql` extension that we provided.

In the `.up.sql` file let's create the table:
```
CREATE TABLE IF NOT EXISTS users(
   user_id serial PRIMARY KEY,
   username VARCHAR (50) UNIQUE NOT NULL,
   password VARCHAR (50) NOT NULL,
   email VARCHAR (300) UNIQUE NOT NULL
);
```
And in the `.down.sql` let's delete it:
```
DROP TABLE IF EXISTS users;
```
By adding `IF EXISTS/IF NOT EXISTS` we are making migrations idempotent - you can read more about idempotency in [getting started](../../GETTING_STARTED.md#create-migrations)

## Run migrations
```
migrate -database ${POSTGRESQL_URL} -path db/migrations up
```
Let's check if the table was created properly by running `psql example -c "\d users"`.
The output you are supposed to see:
```
                                    Table "public.users"
  Column  |          Type          |                        Modifiers                        
----------+------------------------+---------------------------------------------------------
 user_id  | integer                | not null default nextval('users_user_id_seq'::regclass)
 username | character varying(50)  | not null
 password | character varying(50)  | not null
 email    | character varying(300) | not null
Indexes:
    "users_pkey" PRIMARY KEY, btree (user_id)
    "users_email_key" UNIQUE CONSTRAINT, btree (email)
    "users_username_key" UNIQUE CONSTRAINT, btree (username)
```
Great! Now let's check if running reverse migration also works:
```
migrate -database ${POSTGRESQL_URL} -path db/migrations down
```
Make sure to check if your database changed as expected in this case as well.

## Database transactions

To show database transactions usage, let's create another set of migrations by running:
```
migrate create -ext sql -dir db/migrations -seq add_mood_to_users
```
Again, it should create for us two migrations files:
- 000002_add_mood_to_users.down.sql
- 000002_add_mood_to_users.up.sql

In Postgres, when we want our queries to be done in a transaction, we need to wrap it with `BEGIN` and `COMMIT` commands.
In our example, we are going to add a column to our database that can only accept enumerable values or NULL.
Migration up:
```
BEGIN;

CREATE TYPE enum_mood AS ENUM (
	'happy',
	'sad',
	'neutral'
);
ALTER TABLE users ADD COLUMN mood enum_mood;

COMMIT;
```
Migration down:
```
BEGIN;

ALTER TABLE users DROP COLUMN mood;
DROP TYPE enum_mood;

COMMIT;
```

Now we can run our new migration and check the database:
```
migrate -database ${POSTGRESQL_URL} -path db/migrations up
psql example -c "\d users"
```
Expected output:
```
                                    Table "public.users"
  Column  |          Type          |                        Modifiers                        
----------+------------------------+---------------------------------------------------------
 user_id  | integer                | not null default nextval('users_user_id_seq'::regclass)
 username | character varying(50)  | not null
 password | character varying(50)  | not null
 email    | character varying(300) | not null
 mood     | enum_mood              | 
Indexes:
    "users_pkey" PRIMARY KEY, btree (user_id)
    "users_email_key" UNIQUE CONSTRAINT, btree (email)
    "users_username_key" UNIQUE CONSTRAINT, btree (username)
```

## Optional: Run migrations within your Go app
Here is a very simple app running migrations for the above configuration:
```
import (
	"log"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func main() {
	m, err := migrate.New(
		"file://db/migrations",
		"postgres://postgres:postgres@localhost:5432/example?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	if err := m.Up(); err != nil {
		log.Fatal(err)
	}
}
```
You can find details [here](README.md#use-in-your-go-project)

## Fix issue where migrations run twice

When the schema and role names are the same, you might run into issues if you create this schema using migrations.
This is caused by the fact that the [default `search_path`](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH) is `"$user", public`.
In the first run (with an empty database) the migrate table is created in `public`.
When the migrations create the `$user` schema, the next run will store (a new) migrate table in this schema (due to order of schemas in `search_path`) and tries to apply all migrations again (most likely failing).

To solve this you need to change the default `search_path` by removing the `$user` component, so the migrate table is always stored in the (available) `public` schema.
This can be done using the [`search_path` query parameter in the URL](https://github.com/jexia/migrate/blob/fix-postgres-version-table/database/postgres/README.md#postgres).

For example to force the migrations table in the public schema you can use:
```
export POSTGRESQL_URL='postgres://postgres:password@localhost:5432/example?sslmode=disable&search_path=public'
```

Note that you need to explicitly add the schema names to the table names in your migrations when you to modify the tables of the non-public schema.

Alternatively you can add the non-public schema manually (before applying the migrations) if that is possible in your case and let the tool store the migrations table in this schema as well.