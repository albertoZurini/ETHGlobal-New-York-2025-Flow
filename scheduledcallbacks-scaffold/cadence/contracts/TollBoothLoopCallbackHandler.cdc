import "FlowCallbackScheduler"
import "FlowToken"
import "FungibleToken"
import "TollBooth"

access(all) contract TollBoothLoopCallbackHandler {

    /// Handler resource that implements the Scheduled Callback interface
    access(all) resource Handler: FlowCallbackScheduler.CallbackHandler {
        access(FlowCallbackScheduler.Execute) fun executeCallback(id: UInt64, data: AnyStruct?) {
            TollBooth.transferBalance()
            let newBalance1 = TollBooth.getBalance1()
            let newBalance2 = TollBooth.getBalance2()
            log("Callback executed (id: ".concat(id.toString()).concat(") balance1: ").concat(newBalance1.toString()).concat(", balance2: ").concat(newBalance2.toString()))

            // Determine delay for the next callback (default 3 seconds if none provided)
            var delay: UFix64 = 3.0
            if data != nil {
                let t = data!.getType()
                if t.isSubtype(of: Type<UFix64>()) {
                    delay = data as! UFix64
                }
            }

            let future = getCurrentBlock().timestamp + delay
            let priority = FlowCallbackScheduler.Priority.Medium
            let executionEffort: UInt64 = 1000

            let estimate = FlowCallbackScheduler.estimate(
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort
            )

            assert(
                estimate.timestamp != nil || priority == FlowCallbackScheduler.Priority.Low,
                message: estimate.error ?? "estimation failed"
            )

            // Ensure a handler resource exists in the contract account storage
            if TollBoothLoopCallbackHandler.account.storage.borrow<&AnyResource>(from: /storage/TollBoothLoopCallbackHandler) == nil {
                let handler <- TollBoothLoopCallbackHandler.createHandler()
                TollBoothLoopCallbackHandler.account.storage.save(<-handler, to: /storage/TollBoothLoopCallbackHandler)
            }

            // Withdraw FLOW fees from this contract's account vault
            let vaultRef = TollBoothLoopCallbackHandler.account.storage
                .borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("missing FlowToken vault on contract account")
            let fees <- vaultRef.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault

            // Issue a capability to the handler stored in this contract account
            let handlerCap = TollBoothLoopCallbackHandler.account.capabilities.storage
                .issue<auth(FlowCallbackScheduler.Execute) &{FlowCallbackScheduler.CallbackHandler}>(/storage/TollBoothLoopCallbackHandler)

            let receipt = FlowCallbackScheduler.schedule(
                callback: handlerCap,
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort,
                fees: <-fees
            )

            log("Loop callback id: ".concat(receipt.id.toString()).concat(" at ").concat(receipt.timestamp.toString()))
        }
    }

    /// Factory for the handler resource
    access(all) fun createHandler(): @Handler {
        return <- create Handler()
    }
}


