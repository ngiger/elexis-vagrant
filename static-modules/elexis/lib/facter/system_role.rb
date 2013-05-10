require 'facter'
Facter.add("system_role") do
  setcode do
    Facter::Util::Resolution.exec("cat /etc/system_role")
  end
end