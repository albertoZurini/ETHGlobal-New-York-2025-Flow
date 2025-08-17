import "FlowCallbackScheduler"
import "FungibleToken"
import "FlowToken"

// This transaction cancels a scheduled callback by loading the required
// 'ScheduledCallback' object from the signer's account storage.
transaction(callbackId: UInt64) {

    prepare(signer: auth(Storage) &Account) {
        let storagePath = /storage/myScheduledCallbacks

        // 1. Borrow a MUTABLE reference to the Dictionary where the callback objects are stored.
        // This is required so we can call the `.remove()` function.
        let callbackDict = signer.storage.borrow<&Dictionary<UInt64, FlowCallbackScheduler.ScheduledCallback>>(from: storagePath)
            ?? panic("Could not borrow a mutable reference to the callback dictionary at ".concat(storagePath.toString()))

        // 2. Remove the 'ScheduledCallback' object from the dictionary using its ID.
        // This provides the object needed for the cancel function.
        let callbackObject = callbackDict.remove(key: callbackId)
            ?? panic("A callback with the specified ID was not found in your storage.")

        // 3. Call the target function with the retrieved object.
        let refundVault <- FlowCallbackScheduler.cancel(callback: callbackObject)

        // 4. Borrow a reference to the account's main FLOW vault to deposit the refund.
        let vaultRef = signer.storage.borrow<&FlowToken.Vault{FungibleToken.Receiver}>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow a Receiver reference to the FLOW vault")

        // 5. Deposit the refunded fees.
        vaultRef.deposit(from: <-refundVault)

        log("Successfully canceled callback with ID: ".concat(callbackId.toString()))
    }
}