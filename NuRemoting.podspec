#  `pod spec lint NuRemoting.podspec'
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "NuRemoting"
  s.version      = "1.2"
  s.summary      = "Remote control your iOS app using Nu (lisp-on-objc)"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
    Script your iOS app over the network from your Mac. Introspect the state of your app,
    push button, gather stats, or just wirelessly get the console log from your app.
                   DESC

  s.homepage     = "https://github.com/nevyn/NuRemoting"
  s.screenshots  = "https://camo.githubusercontent.com/bbdbb3dc7914b665062ccde639cd52f6d1107709/687474703a2f2f662e636c2e6c792f6974656d732f3333304a305534363351334430413275303331422f53637265656e25323053686f74253230323031312d31302d3331253230617425323032312e33342e33392e706e67"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Nevyn Bengtsson" => "nevyn.jpg@gmail.com" }
  s.social_media_url   = "http://twitter.com/nevyn"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/nevyn/NuRemoting.git", :tag => "#{s.version}" }
  s.frameworks = "CFNetwork"
  s.requires_arc = true
  
  s.subspec 'arc' do |ss|
    ss.public_header_files = "NuRemote/*.h"
    ss.source_files  = "NuRemote"
    ss.requires_arc = true
  end
  s.subspec 'no-arc' do |ss|
    ss.source_files  = "Examples/Support/objc/*.{h,m}"
    ss.requires_arc = false
  end

end
