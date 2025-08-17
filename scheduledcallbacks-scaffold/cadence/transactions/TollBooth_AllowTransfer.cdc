import "TollBooth"

transaction {

    prepare(acct: &Account) {
        // Authorizes the transaction
    }

    execute {
        TollBooth.setTransferAllowance(true)
        let newVal = TollBooth.isTransferAllowed
        log("Transfer allowance: \(newVal)")
    }
}
