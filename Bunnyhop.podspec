Pod::Spec.new do |s|
  s.name         = "Bunnyhop"
  s.version      = "0.1.0"
  s.summary      = "Simple and clean JSON for Swift "
  s.homepage     = "https://github.com/wheely/Bunnyhop"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Wheely " => "pbo@wheely.com" }
  s.source       = { :git => "https://github.com/wheely/Bunnyhop.git", :tag => s.version }
  s.platform     = :ios, '7.0'
  s.source_files = 'Bunnyhop', '*.{h,m}'
  s.requires_arc = true
end