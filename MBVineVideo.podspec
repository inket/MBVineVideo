Pod::Spec.new do |s|
  s.name             = "MBVineVideo"
  s.version          = "1.0.0"
  s.summary          = "Extracts video url and information from Vine"
  s.homepage         = "https://github.com/inket/MBVineVideo"
  s.license          = 'MIT'
  s.author           = { "inket" => "injekter@gmail.com" }
  s.source           = { :git => "https://github.com/inket/MBVineVideo.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/inket'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'Ono', '~> 1.1'
end
