require 'blocktrail'

client = Blocktrail::Client.new(api_key: 'YOUR_API_KEY_HERE', api_secret:'YOUR_API_SECRET_HERE')

# If the enviroment variables YOUR_API_KEY_HERE and YOUR_API_SECRET_HERE'
# are defined you can just do:
client = Blocktrail::Client.new

address = client.address('1dice8EMZmqKvrGE4Qc9bUFf9PX3xaYDp')
client.price
client.address_transactions('1dice8EMZmqKvrGE4Qc9bUFf9PX3xaYDp')['data']
client.verify_address('16dwJmR4mX5RguGrocMfN9Q9FR2kZcLw2z', 'HPMOHRgPSMKdXrU6AqQs/i9S7alOakkHsJiqLGmInt05Cxj6b/WhS7kJxbIQxKmDW08YKzoFnbVZIoTI2qofEzk=')

# with testnet, debug info for the Bitcoin network:
client = Blocktrail::Client.new(api_key:'YOUR_API_KEY_HERE', api_secret:'YOUR_API_SECRET_HERE', testnet: true, debug: true, bitcoin_cash: false)

# If the enviroment variables YOUR_API_KEY_HERE and YOUR_API_SECRET_HERE'
# are defined you can just do:
client = Blocktrail::Client.new(testnet: true, debug: true, bitcoin_cash: false)
