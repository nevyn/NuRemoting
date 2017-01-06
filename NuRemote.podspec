Pod::Spec.new do |s|
  s.name         = "NuRemote"
  s.version      = "1.1"
  s.summary      = "Developer tool: Remote control your iOS app using Nu (lisp-on-objc)"

  s.description  = <<-DESC
  This project lets you send code into an instance of your app running on the same
  network. Install this pod into your app, then run `[[SPNuRemote new] run]` in your
  app delegate, and you're up and running. Download the Mac app NuRemoter from
  https://github.com/nevyn/NuRemoting/releases to control your app,
  see its console output, and receive live stats.
                   DESC

  s.homepage     = "https://github.com/nevyn/NuRemoting"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Nevyn Bengtsson" => "nevyn.jpg@gmail.com" }
  s.social_media_url   = "http://twitter.com/nevyn"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/nevyn/NuRemoting.git", :tag => "#{s.version}" }
  s.source_files  = [
    "NuRemote/Shared.h",
    "NuRemote/RemotingClient.h",
    "NuRemote/RemotingClient.m",
    "NuRemote/NRStats.h",
    "NuRemote/NRStats.m",
    "NuRemote/SPNuRemote.h",
    "NuRemote/SPNuRemote.m",
  ]
  
  s.dependency 'Nu', '~> 2.0'
  s.dependency "CocoaAsyncSocket", "~> 2.0"

  # This project is old, ok?
  s.requires_arc = false

end
