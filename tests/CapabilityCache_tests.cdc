import Test
import "test_helpers.cdc"

import "CapabilityCache"
import "FungibleToken"

access(all) let DefaultNamespace = "CapabilityCache_tests"

// Tests
// ------------------------------------------------------
access(all) fun testImport() {
    Test.assert(scriptExecutor("import.cdc", [])! as! Bool, message: "import script failed")
}

access(all) fun testSetupCache() {
    let acct = getNewAccount()
    Test.assert(
        !(scriptExecutor("check_for_cache.cdc", [acct.address, DefaultNamespace])! as! Bool),
        message: "cache was found when it should not be"
    )
    setupCache(acct, namespace: DefaultNamespace)
    Test.assert(
        scriptExecutor("check_for_cache.cdc", [acct.address, DefaultNamespace])! as! Bool,
        message: "cache was found when it should not be"
    )
}

access(all) fun testAddTypeToCache() {
    let acct = getNewAccount()
    let s = /storage/flowTokenVault
    let t = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()
    addTypeToCache(acct, namespace: DefaultNamespace, type: t, path: s)

    let e = Test.eventsOfType(Type<CapabilityCache.CapabilityAdded>()).removeLast() as! CapabilityCache.CapabilityAdded
    Test.assertEqual(t, e.capabilityType)
}

access(all) fun testBorrowCachedCapability() {
    let acct = getNewAccount()
    let s = /storage/flowTokenVault
    let t = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()
    addTypeToCache(acct, namespace: DefaultNamespace, type: t, path: s)

    txExecutor("get_ft_provider_capability_from_cache.cdc", [acct], [DefaultNamespace])
}

access(all) fun testRemoveCachedCapability() {
    let acct = getNewAccount()
    let s = /storage/flowTokenVault
    let t = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()
    
    addTypeToCache(acct, namespace: DefaultNamespace, type: t, path: s)
    let addEvent = Test.eventsOfType(Type<CapabilityCache.CapabilityAdded>()).removeLast() as! CapabilityCache.CapabilityAdded

    removeTypeFromCache(acct, namespace: DefaultNamespace, type: t, path: s)
    let removeEvent = Test.eventsOfType(Type<CapabilityCache.CapabilityRemoved>()).removeLast() as! CapabilityCache.CapabilityRemoved

    Test.assertEqual(addEvent.capabilityID, removeEvent.capabilityID)
}

// Helper Methods For tests
// ------------------------------------------------------

access(all) fun setupCache(_ acct: Test.TestAccount, namespace: String) {
    txExecutor("setup.cdc", [acct], [namespace])
}

access(all) fun addTypeToCache(_ acct: Test.TestAccount, namespace: String, type: Type, path: StoragePath) {
    txExecutor("add_type_to_cache.cdc", [acct], [namespace, type, path])
}

access(all) fun removeTypeFromCache(_ acct: Test.TestAccount, namespace: String, type: Type, path: StoragePath) {
    txExecutor("remove_cached_capability.cdc", [acct], [namespace, type])
}

// Test framework hooks
// ------------------------------------------------------

access(all) fun setup() {
    deployAll()
}