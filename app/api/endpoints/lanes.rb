
class ::Endpoints::Lanes < ::Core::Endpoint::Base
  model do
  end

  instance do
    has_many(:requests, json: 'requests', to: 'requests')
  end
end
