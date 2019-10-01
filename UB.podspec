Pod::Spec.new do |spec|
	spec.name = 'UB'
	spec.version = '0.2.0'
	spec.authors = {'Eric Tu' => 'eric@chainsafe.io', 'Dean Eigenmann' => 'dean@status.im'}
	spec.homepage = 'https://github.com/ultralight-beam/UB.swift'
	spec.license = { :type => 'Apache' }
	spec.source = { :git => 'https://github.com/ultralight-beam/UB.swift.git', :tag => 'v0.2.0'}
	spec.source_files = 'Sources/UB/*.swift'
	spec.summary = 'MANETs'
	spec.swift_version = '5.0'
 	spec.ios.deployment_target = '9.0'
	spec.osx.deployment_target = '10.13'
	spec.dependency 'SwiftProtobuf'
end
