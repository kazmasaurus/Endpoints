

task :start => :'API:start'

namespace :API do

    desc 'Start the server'
    task :start do
        sh('cd Carthage/Checkouts/endpoints-example; npm install && npm start;')
    end
end
