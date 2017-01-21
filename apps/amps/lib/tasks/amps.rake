namespace :amps do

  namespace :server do
    task :d do
      sh "mongrel_rails start -e development --prefix /amps"
    end
    task :p do
      sh "mongrel_rails start -e production --prefix /amps"
    end
  end
  
  task :clear_cache do
    sh "rm -rf ./public/sentence"
    sh "rm -rf ./public/frame"
    sh "rm -rf ./tmp/cache/*"
  end

  namespace :draw do
    task :models do
      sh "railroad -M --hide-types -e user.rb,wiki.rb -i | dot -Tpng > ./public/images/models.png"
    end
  end
end
