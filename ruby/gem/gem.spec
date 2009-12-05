require 'rubygems'

spec = Gem::Specification.new {|s|
  s.name     = 'phprpc'
  s.version  = '3.0.5'
  s.author   = 'MA Bingyao ( andot )'
  s.email    = 'andot@ujn.edu.cn'
  s.homepage = 'http://phprpc.rubyforge.org/'
  s.rubyforge_project = 'phprpc'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'PHPRPC is a Remote Procedure Calling protocol that works over
                the Internet. It is secure and fast. It has a smaller overhead.
                It is powerful and easy to use. This project is the client and
                server implementations of the PHPRPC for Ruby.'
  candidates = Dir.glob '{examples,lib}/**/*'
  candidates += Dir.glob '*'
  s.files    = candidates.delete_if { |item|
                 item.include?('CVS') || item.include?('rdoc') ||
                 item.include?('nbproject') ||
                 File.extname(item) == '.spec'
               }
  s.require_path = 'lib'
  s.has_rdoc     = false
}

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end