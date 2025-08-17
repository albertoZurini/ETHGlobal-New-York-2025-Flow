import "TollBooth"

access(all)
fun main(): {String: Int} {
    return {
        "balance1": TollBooth.balance1,
        "balance2": TollBooth.balance2
    }
}
