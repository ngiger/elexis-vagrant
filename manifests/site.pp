# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

node "ng-hp" {
    notify { "site.pp node puppet": }
    include x2go
}
node default {
    notify { "site.pp node default": }
    include x2go
}
