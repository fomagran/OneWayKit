#
# Be sure to run `pod lib lint OneWayKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OneWayKit'
  s.version          = '0.1.0'
  s.summary          = 'OneWayKit is a lightweight unidirectional data flow framework for simplifying state management in iOS applications. It ensures predictable state transitions with centralized state management and consistent action dispatching. Optimized for Swift, OneWayKit promotes maintainable and scalable architecture.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/47676921/OneWayKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '47676921' => 'fomagran@icloud.com' }
  s.source           = { :git => 'https://github.com/fomagran/OneWayKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'OneWayKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OneWayKit' => ['OneWayKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
