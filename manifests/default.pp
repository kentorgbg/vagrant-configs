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

apt::ppa { "ppa:pitti/postgresql":
} ->

class { "postgresql":
    version => $postgresql_version
} ->
class { "postgresql::devel":
} ->
class { "postgresql::server":
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
