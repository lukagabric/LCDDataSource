Pod::Spec.new do |s|
  s.name         = "LCDDataSource"
  s.version      = "1.0"
  s.platform     = :ios, '6.0'
  s.source       = { :git => 'https://github.com/lukagabric/LCDDataSource'}
  s.source_files = "LCDDataSource/LCDDataSource/Classes/Core/ClassExtensions/*.{h,m}", "LCDDataSource/LCDDataSource/Classes/Core/LDataUpdate/*.{h,m}", "LCDDataSource/LCDDataSource/Classes/Core/LDataUpdate/PromiseKit/*.{h,m}", "LCDDataSource/LCDDataSource/Classes/Core/LAbstractCDParser/*.{h,m}", "LCDDataSource/LCDDataSource/Classes/Core/LCoreDataController/*.{h,m}"
  s.framework    = 'CoreData'
  s.dependency 'PromiseKit'
  s.dependency 'ASIHTTPRequest'
  s.dependency 'MBProgressHUD'
  s.requires_arc = true
end
