
Pod::Spec.new do |s|
  s.name         = "SMOSmRongim"
  s.version      = "1.0.0"
  s.summary      = "SMOSmRongim"
  s.description  = <<-DESC
                  SMOSmRongim
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/author/SMOSmRongim.git", :tag => "master" }
  s.source_files  = "SMOSmRongim/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  