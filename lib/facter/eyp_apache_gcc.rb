gcc = Facter::Util::Resolution.exec('bash -c \'c++ -v 2>&1 | tail -1 | grep gcc\'').to_s

unless gcc.nil? or gcc.empty?
  Facter.add('eyp_apache_gcc') do
      setcode do
        gcc
      end
  end
end
