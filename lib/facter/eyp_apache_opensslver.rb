#
opensslver = Facter::Util::Resolution.exec('bash -c \'openssl version 2>/dev/null | awk "{ print \$2 }"\'').to_s

unless opensslver.nil? or opensslver.empty?
  Facter.add('eyp_apache_opensslver') do
      setcode do
        opensslver
      end
  end
end
