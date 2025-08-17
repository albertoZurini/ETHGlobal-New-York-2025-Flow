import "TollBooth"

transaction {

    prepare(acct: &Account) {
        // Authorizes the transaction
    }

    execute {
        TollBooth.setTransferAllowance(true)
        TollBooth.transferBalance()
        log("transferBalance() called successfully")
    }
}
