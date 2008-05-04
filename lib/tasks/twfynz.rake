namespace :kiwimp do
  task :init do
    `git submodule init`
    `git submodule update`
  end
end
