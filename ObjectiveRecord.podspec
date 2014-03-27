Pod::Spec.new do |s|
  s.name     = 'ObjectiveRecord'
  s.version  = '1.5.0'
  s.summary  = 'Lightweight and sexy Core Data finders and creators. Rails syntax.'
  s.homepage = 'https://github.com/supermarin/ObjectiveRecord'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }

  s.author   = { 'Marin Usalj' => 'mneorr@gmail.com' }
  s.source   = {
    :git => 'https://github.com/supermarin/ObjectiveRecord.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '4.0'
  s.osx.deployment_target = '10.6'
  s.requires_arc = true

  s.source_files = 'Classes/**/*'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'

  s.frameworks = 'CoreData'
  s.dependency 'ObjectiveSugar'
end
