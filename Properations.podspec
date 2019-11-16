Pod::Spec.new do |spec|
spec.name         = 'Properations'
spec.version      = '0.2.0'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'https://github.com/benedictc/properations'
spec.authors      = { 'Benedict Cohen' => 'ben@benedictcohen.co.uk' }
spec.summary      = 'Concurrency framework based on futures and promises implemented using `Operation` and `OperationQueue`.'
spec.source       = { :git => 'https://github.com/benedictc/properations.git', :tag => 'v0.2.0'}
spec.source_files = 'Properations/**/*.swift'
spec.ios.deployment_target = '10.0'
spec.swift_versions = ['4.0', '5.0']
end
