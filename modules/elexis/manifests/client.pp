# Here we define a few packages which are common to all elexis instances
class elexis::client inherits elexis::common {

  include x2go::client
  include java

}
