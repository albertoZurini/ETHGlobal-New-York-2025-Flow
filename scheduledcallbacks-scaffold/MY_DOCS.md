# Run the emulator

flow emulator --scheduled-callbacks --block-time 1s

# Deploy the contracts

flow project deploy --network emulator

# Initialize handler capabilities

flow transactions send cadence/transactions/TollBooth_InitTollBoothLoopCallbackHandler.cdc \
  --network emulator \
  --signer emulator-account

# Schedule an increment

```
flow transactions send cadence/transactions/TollBooth_ScheduleTransferBalanceInLoop.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UFix64","value":"2.0"},      
    {"type":"UInt8","value":"1"},        
    {"type":"UInt64","value":"1000"},     
    {"type":"Optional","value":null}
  ]'
```

```
flow transactions send cadence/transactions/ScheduleIncrementInLoop.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UFix64","value":"2.0"},      
    {"type":"UInt8","value":"1"},        
    {"type":"UInt64","value":"1000"},     
    {"type":"Optional","value":null}
  ]'
```
# Get balances values

flow scripts execute cadence/scripts/GetBalances.cdc --network emulator

flow scripts execute cadence/scripts/GetLastTransactionTime.cdc --network emulator

# Test function

flow transactions send cadence/transactions/TollBooth_TransferBalance.cdc \
  --network emulator \
  --signer emulator-account

flow transactions send cadence/transactions/TollBooth_AllowTransfer.cdc \
  --network emulator \
  --signer emulator-account

# Not working

flow transactions send cadence/transactions/CancelScheduler.cdc \
  --network emulator \
  --signer emulator-account \
  --args-json '[
    {"type":"UInt64","value":"1"}
  ]'

