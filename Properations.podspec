Pod::Spec.new do |spec|
spec.name         = 'Properations'
spec.version      = '0.1.0'
spec.license      = { :type => 'MIT' }
spec.homepage     = 'http://github.com/benedictc/properations'
spec.authors      = { 'Benedict Cohen' => 'ben@benedictcohen.co.uk' }
spec.summary      = 'Concurrency framework based on futures and promises implemented using `Operation` and `OperationQueue`.'
spec.source       = { :git => 'http://github.com/benedictc/properations' }
spec.source_files = 'Properations/**/*.swift'
spec.ios.deployment_target = '10.0'
end


