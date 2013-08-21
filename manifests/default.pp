exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

include apt

package { [ "vim",
            "build-essential", 
            "zlib1g-dev", 
            "libssl-dev", 
            "libreadline-dev", 
            "libxml2", 
            "libxml2-dev", 
            "libxslt1-dev"]:
    ensure => installed
}

class { "locales":
  default_value => "en_US.UTF-8",
  available     => [ "en_US.UTF-8 UTF-8", "sv_SE.UTF-8 UTF-8" ]
} ->

apt::ppa { "ppa:pitti/postgresql":
} ->

class { "postgresql":
    version => $postgresql_version
} ->
class { "postgresql::devel":
} ->
class { "postgresql::server":
    config_hash => {
        "ipv4acls" => [
            "host all all 127.0.0.1/32 trust" # Overrides the default md5 auth for all users
        ]
    }
} ->

exec { "Fix encoding for Postgres templates":
    command => "psql -c \"update pg_database set encoding = pg_char_to_encoding('UTF8') where datistemplate = true;\" postgres",
    path    => "/usr/bin",
    user    => "postgres"
} ->

postgresql::role { "vagrant":
    createdb  => true,
    superuser => true,
    login     => true
}

rbenv::install { "vagrant": } ->
rbenv::compile { $ruby_version:
    user => "vagrant",
    global => true
}
