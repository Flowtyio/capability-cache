import "CapabilityCache"
import "FungibleToken"

transaction(namespace: String) {
    prepare(acct: auth(BorrowValue) &Account) {
        let type = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()

        let s = CapabilityCache.getPathForCache(namespace)
        let cache = acct.storage.borrow<auth(CapabilityCache.Get) &CapabilityCache.Cache>(from: s)
            ?? panic("cache not found in storage")
        let cap = cache.getCapabilityByType(type)
            ?? panic("capability not found with provided type")
        let casted = cap as! Capability<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>
        casted.borrow() ?? panic("failed to borrow provider capability")
    }
}