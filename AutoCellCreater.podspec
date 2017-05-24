
Pod::Spec.new do |s|
s.name                  = 'AutoCellCreater'
s.version               = '1.2'
s.summary               = '自动构建cell'
s.homepage              = 'https://github.com/heroims/AutoCellCreater'
s.license               = { :type => 'MIT', :file => 'README.md' }
s.author                = { 'heroims' => 'heroims@163.com' }
s.source                = { :git => 'https://github.com/heroims/AutoCellCreater.git', :tag => "#{s.version}" }
s.platform              = :ios, '6.0'
s.source_files          = 'AutoCellCreater.h'
s.subspec 'AutoCellCreaterTableView' do |ss|
ss.source_files = 'AutoCellCreaterTableView/*.{h,m}'
end
s.subspec 'AutoCellCreaterCollectionView' do |sss|
sss.source_files = 'AutoCellCreaterCollectionView/*.{h,m}'
end
s.requires_arc          = true
end
