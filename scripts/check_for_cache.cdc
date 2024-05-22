import "CapabilityCache"

access(all) fun main(addr: Address, namespace: String): Bool {
    let s = CapabilityCache.getPathForCache(namespace)

    let acct = getAuthAccount<auth(BorrowValue) &Account>(addr)
    return acct.storage.borrow<&CapabilityCache.Cache>(from: s) != nil
}