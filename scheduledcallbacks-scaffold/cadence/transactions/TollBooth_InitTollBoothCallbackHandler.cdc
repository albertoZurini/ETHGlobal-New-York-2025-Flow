import "TollBoothLoopCallbackHandler"
import "FlowCallbackScheduler"

transaction() {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Save a handler resource to storage if not already present
        if signer.storage.borrow<&AnyResource>(from: /storage/TollBoothLoopCallbackHandler) == nil {
            let handler <- TollBoothLoopCallbackHandler.createHandler()
            signer.storage.save(<-handler, to: /storage/TollBoothLoopCallbackHandler)
        }

        // Validation/example that we can create an issue a handler capability with correct entitlement for FlowCallbackScheduler
        let _ = signer.capabilities.storage
            .issue<auth(FlowCallbackScheduler.Execute) &{FlowCallbackScheduler.CallbackHandler}>(/storage/TollBoothLoopCallbackHandler)
    }
}


