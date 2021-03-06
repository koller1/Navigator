
Pod::Spec.new do |s|

  s.name         = 'Navigator'
  s.version      = '0.3.7'
  s.summary      = 'Router for iOS view navigation & animation'
  s.description  = <<-DESC 
                   Navigator is a router for tracking application state and transitioning between views. It provides default 
                   implementations for managing UINavigationController's stack and displaying views modally, and it provides 
                   extension points for custom navigation hierarchies and animations.
                   DESC

  s.homepage     = 'http://github.com/derkis/Navigator'
  s.author       = { 'Ty Cobb' => 'ty.cobb.m@gmail.com' } 
  s.license      = { :type => 'MIT', :file => 'License.txt' }
 
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source       = { :git => 'https://github.com/derkis/Navigator.git', :tag => "v#{s.version}" }  
  
  s.subspec 'Core' do |ss|
    paths = [ '', 'Router/', 'Routes/', 'Transitions/', 'Updates/', 'Shared/' ].map do |dir|
      "Navigator/#{dir}"
    end

    ss.source_files = paths.map { |path| path + '*.{h,m}' }
    ss.public_header_files = paths.map { |path| path + '*.h' } 
  end

  s.subspec 'View' do |ss|
    ss.dependency 'Navigator/Core'
    ss.source_files = 'Navigator/View/*.{h,m}'
    ss.public_header_files = 'Navigator/View/*.h'
    ss.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'NAVIGATOR_VIEW' }
  end
  
  s.dependency 'YOLOKit', '~> 11'
  
  yolo_preprocessor_defines = %w{
    last skip snip split join extend select map find concat uniq array dict first inject flatten
  }.reduce('') do |memo, subspec|
    memo + "YOLO_#{subspec.upcase}=1 "
  end.strip

  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => yolo_preprocessor_defines }

end
