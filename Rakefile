require 'rake/testtask'

Rake::TestTask.new do |t|
  t.warning = true
end


require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
end


'lib/yajp/parse.tab.rb'.then do |dest|
  desc "Generate #{dest} by Racc"
  task 'racc' => dest
end

rule '.tab.rb' => '.ry' do |t|
  dir, base = File.split(t.prerequisites.first)
  cd dir
  sh 'racc', '-t', base
end

