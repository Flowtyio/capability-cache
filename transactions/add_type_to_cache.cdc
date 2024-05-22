import "CapabilityCache"

transaction(namespace: String, type: Type, path: StoragePath) {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let s = CapabilityCache.getPathForCache(namespace)
        if acct.storage.borrow<&CapabilityCache.Cache>(from: s) == nil {
            let c <- CapabilityCache.createCache(namespace: namespace)
            acct.storage.save(<-c, to: s)
        }

        let cache = acct.storage.borrow<auth(CapabilityCache.Add) &CapabilityCache.Cache>(from: s)
            ?? panic("capability cache was not found")

        let cap = acct.capabilities.storage.issueWithType(path, type: type)
        cache.addCapability(cap: cap, type: type)
    }
}