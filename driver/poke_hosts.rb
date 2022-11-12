require 'new_api'
require 'pp'

def poke_host(host)
  puts "Poking #{host}..."
  api = new_api(host)
  begin
    # lists available validators
    result = api.get_validators
    puts "Validators detected: #{result.length}"
    result.each do |val|
      puts "   #{val.validator_id}: #{val.description}"
    end
  rescue ValidatorClient::ApiError => e
    puts "Exception when calling ValidationApi->get_validators: #{e}"
  end
end

poke_host("v09:8080")
poke_host("v09x:8080")
poke_host("v010:8080")
poke_host("v010x:8080")
