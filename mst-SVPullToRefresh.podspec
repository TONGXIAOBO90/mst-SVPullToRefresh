#
#  Be sure to run `pod spec lint mst-SVPullToRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "mst-SVPullToRefresh"
  s.version      = "0.0.1"
  s.summary      = "A short description of mst-SVPullToRefresh."
  s.description  = <<-DESC
                   A longer description of mst-SVPullToRefresh in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://github.com/tongshi/mst-SVPullToRefresh"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author             = { "tongxb" => "tongxb@mst365.cn" }
  s.source       = { :git => "git@github.com:tongshi/mst-SVPullToRefresh.git”, branch => ‘master’ }

  s.source_files  = “mst-SVPullToRefresh/“
  #s.exclude_files = "Classes/Exclude"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
