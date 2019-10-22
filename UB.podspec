Pod::Spec.new do |spec|
	spec.name = 'UB'
	spec.version = '0.2.0'
	spec.authors = {'Eric Tu' => 'eric@chainsafe.io', 'Dean Eigenmann' => 'dean@status.im'}
	spec.homepage = 'https://github.com/ultralight-beam/UB.swift'
	spec.license = { :type => 'Apache' }
	spec.source = { :git => 'https://github.com/ultralight-beam/UB.swift.git', :tag => 'v0.2.0'}
	spec.source_files = 'Sources/UB/**/*.swift'
	spec.summary = 'Swift implementation of the Ultralight Beam protocol'
	spec.swift_version = '5.1'
 	spec.ios.deployment_target = '13.0'
	spec.osx.deployment_target = '10.13'
	spec.dependency 'SwiftProtobuf'
end
