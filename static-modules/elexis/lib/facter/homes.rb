require 'facter'

Facter.add("homes") do
  setcode do
    Dir.glob('/home/*').join(',')
  end
end
    

