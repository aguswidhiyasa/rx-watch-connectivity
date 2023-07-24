Pod::Spec.new do |spec|
    spec.name         = 'RxWatchConnectivity'
    spec.version      = '0.1.0'
    spec.authors      = { 
        'Agus Widhiyasa' => 'widhiyasa.bigbangfuzion@outlook.com'
    }
    spec.license      = { 
        :type => 'MIT',
        :file => 'LICENSE' 
    }
    spec.homepage     = 'https://aguswidhiyasa.com'
    spec.source       = { 
        :git => 'https://github.com/aguswidhiyasa/RxWatchConnectivity.git', 
        :branch => 'master',
        :tag => spec.version.to_s 
    }
    spec.summary      = 'Custom Watch Connectivity wrapper using RxSwift'
    spec.source_files = '**/*.swift', '*.swift'
    spec.swift_versions = '5.1'
    spec.ios.deployment_target = '12.0'
    spec.deployment_target = '12.0'

    spec.dependency "RxSwift"

    spec.test_spec 'RxWatchConnectivityTests' do |test_spec|
        test_spec.source_files = 'RxWatchConnectivityTests/*.swift'
        test_spec.dependency 'RxBlocking'
    end
end