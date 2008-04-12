namespace :doc do
  desc "Generate documentation for the application."
  task :app do
    files = ['doc/README.txt', 'doc/TODO.txt', 'app/**/*.rb', 'lib/**/*.rb']
    filenames = files.map {|f| Dir[Merb.root + '/' + f].join(' ') }.join(' ')
    
    system "rdoc -t 'GoPlay Application Documentation' -o doc/app --line-numbers --inline-source --charset utf8 -a #{filenames}"
  end
  
  desc "Remove application documentation"
  task :clobber_app do 
    rm_rf 'doc/app' rescue nil
  end
end
