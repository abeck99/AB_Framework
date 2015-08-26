Pod::Spec.new do |s|
	s.name		= 'AB_Framework'
	s.version	= '0.1.0'
	s.summary	= 'A (currently) highly unstable library for building view based applications in iOS'
	s.author	= {
		'Andrew Beck' => 'abeck99@gmail.com'
	}
	s.source 	= {
		:git => 'https://github.com/abeck99/AB_Framework.git',
		:tag => '0.1.0'
	}
	s.license	= {
		:type => 'MIT',
		:file => 'LICENSE.md'
	}
	s.source_files = 'src/**/*.{h,m,inl}'
	s.resources = 'src/**/*.{xib}'
	s.requires_arc = true
	s.homepage = 'https://github.com/abeck99/AB_Framework'
	s.dependency 'ReactiveCocoa'
	s.dependency 'Mantle'
	s.dependency 'LoremIpsum'

	s.ios.deployment_target = '8.0'
end