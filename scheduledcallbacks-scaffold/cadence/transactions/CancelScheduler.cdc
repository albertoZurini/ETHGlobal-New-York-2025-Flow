import "FlowCallbackScheduler"

/// Cancel a scheduled callback using its ID
transaction(callbackId: UInt64) {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        FlowCallbackScheduler.cancel(id: callbackId)
        log("Attempted to cancel callback with id: ".concat(callbackId.toString()))
    }
}