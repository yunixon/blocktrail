require 'blocktrail'

client = Blocktrail::Client.new('YOUR_API_KEY_HERE', 'YOUR_API_SECRET_HERE')

address = client.address('1dice8EMZmqKvrGE4Qc9bUFf9PX3xaYDp')
client.price
client.address_transactions('1dice8EMZmqKvrGE4Qc9bUFf9PX3xaYDp')['data']
client.verify_address('16dwJmR4mX5RguGrocMfN9Q9FR2kZcLw2z', 'HPMOHRgPSMKdXrU6AqQs/i9S7alOakkHsJiqLGmInt05Cxj6b/WhS7kJxbIQxKmDW08YKzoFnbVZIoTI2qofEzk=')

# with testnet and debug info
client = Blocktrail::Client.new('YOUR_API_KEY_HERE', 'YOUR_API_SECRET_HERE', 'v1', true, true)
