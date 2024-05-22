import "CapabilityCache"

transaction(namespace: String, type: Type) {
    prepare(acct: auth(BorrowValue) &Account) {
        let s = CapabilityCache.getPathForCache(namespace)
        let cache = acct.storage.borrow<auth(CapabilityCache.Delete) &CapabilityCache.Cache>(from: s)
            ?? panic("cache not found in storage")

        cache.removeCapabilityByType(type)
    }
}