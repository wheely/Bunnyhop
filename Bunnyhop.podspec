Pod::Spec.new do |s|
  s.name         = "Bunnyhop"
  s.version      = "0.1"
  s.summary      = "JSON library for Swift that extensively uses type inference and no extra syntax"
  s.homepage     = "https://github.com/wheely/Bunnyhop"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Wheely" => "pavel@wheely.com" }
  s.source       = { :git => "https://github.com/wheely/Bunnyhop.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '7.0'
  s.source_files = 'Bunnyhop', '*.{h,m}'
  s.requires_arc = true
end
