access(all) contract TollBooth {

    // Declare public, variable integer fields for balances.
    access(all) var balance1: Int
    access(all) var balance2: Int

    // Declare a public, variable boolean to control transfer logic.
    access(all) var isTransferAllowed: Bool

    // A new global variable to store the timestamp of the last successful transfer.
    // It's an optional UFix64, so it will be `nil` until the first transfer occurs.
    access(all) var lastTransferTimestamp: UFix64?

    // The init function is the contract's constructor.
    // It is only called once when the contract is deployed.
    init() {
        self.balance1 = 100
        self.balance2 = 0
        self.isTransferAllowed = false // Transfers are disabled by default.
        self.lastTransferTimestamp = nil // Initialize the timestamp as nil.
    }

    // Transfers 1 from balance1 to balance2.
    // The transaction will fail if balance1 is not > 0 or if isTransferAllowed is false.
    access(all) fun transferBalance() {
        pre {
            // self.isTransferAllowed == true: "Transfers are currently disabled."
            self.balance1 > 0: "Insufficient balance in balance1 to perform the transfer."
        }
        if self.isTransferAllowed {
            self.balance1 = self.balance1 - 1
            self.balance2 = self.balance2 + 1
            // On successful transfer, update the timestamp to the current block's timestamp.
            self.lastTransferTimestamp = getCurrentBlock().timestamp
        }
    }

    // Sets the value of balance1 to a new integer value.
    access(all) fun setBalance1(_ newBalance: Int) {
        self.balance1 = newBalance
    }

    // Sets the value of balance2 to a new integer value.
    access(all) fun setBalance2(_ newBalance: Int) {
        self.balance2 = newBalance
    }

    // Public getter for balance1
    access(all) fun getBalance1(): Int {
        return self.balance1;
    }

    // Public getter for balance2
    access(all) fun getBalance2(): Int {
        return self.balance2;
    }

    // New public getter for the last transfer timestamp.
    // Returns an optional UFix64 (`UFix64?`).
    access(all) fun getLastTransferTimestamp(): UFix64? {
        return self.lastTransferTimestamp
    }

    // Sets the boolean flag to enable or disable transfers.
    access(all) fun setTransferAllowance(_ isAllowed: Bool) {
        self.isTransferAllowed = isAllowed
    }
}