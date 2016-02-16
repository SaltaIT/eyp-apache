make = Facter::Util::Resolution.exec('bash -c \'make -v | head -n1 | grep -i make\'').to_s

unless make.nil? or make.empty?
  Facter.add('eyp_apache_make') do
      setcode do
        make
      end
  end
end
