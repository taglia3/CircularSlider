Pod::Spec.new do |s|
  s.name             = 'CircularSlider'
  s.version          = '0.1'
  s.summary          = 'A beautiful Circular Slider'
  s.description      = <<-DESC
A beautiful Circular Slider A beautiful Circular Slider A beautiful Circular Slider A beautiful Circular Slider A beautiful Circular Slider.
                       DESC

  s.homepage         = 'https://github.com/taglia3/CircularSlider'
  s.license          = 'MIT'
  s.author           = { "taglia3" => "the.taglia3@gmail.com" }
  s.source           = { :git => "https://github.com/taglia3/CircularSlider.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/taglia3'
  s.source_files      = 'CircularSliderExample/CircularSlider/**/*.{swift,xib}'
  s.frameworks        = 'UIKit'
  s.ios.deployment_target = '8.0'
end