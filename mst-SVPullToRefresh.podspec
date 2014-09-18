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
  s.summary      = ""

  s.description  = <<-DESC
                   A longer description of mst-SVPullToRefresh in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/tongshi/mst-SVPullToRefresh"
  s.license      = "MIT (example)"  
  s.author             = { "tongshi" => "email@address.com" }
  s.source       = { :git => "https://github.com/tongshi/mst-SVPullToRefresh.git", :tag => "0.0.1" }
  s.source_files  = "mst-SVPullToRefresh/“
  s.requires_arc = true

end
