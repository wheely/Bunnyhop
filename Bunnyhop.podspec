Pod::Spec.new do |spec|
    spec.name = 'Bunnyhop'
    spec.version = '1.0'
    spec.license = { 'type' => 'MIT' }
    spec.homepage = 'https://github.com/wheely/Bunnyhop'
    spec.authors = { 'Pavel Bocharov' => 'pavelbocharov@gmail.com' }
    spec.summary = 'Simple and clean JSON for Swift'
    spec.source = {
        :git => 'https://github.com/wheely/Bunnyhop',
        :tag => "v#{spec.version}"
    }
    spec.source_files = 'Bunnyhop/*.swift'
end
