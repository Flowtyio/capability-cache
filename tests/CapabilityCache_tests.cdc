import Test
import "test_helpers.cdc"

import "CapabilityCache"
import "FungibleToken"
import "FlowToken"

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
    addTypeToCache(acct, namespace: DefaultNamespace, resourceType: Type<@FlowToken.Vault>(), capIssueType: t, path: s)

    let e = Test.eventsOfType(Type<CapabilityCache.CapabilityAdded>()).removeLast() as! CapabilityCache.CapabilityAdded
    Test.assertEqual(CapabilityType(t)!, e.capabilityType)
}

access(all) fun testBorrowCachedCapability() {
    let acct = getNewAccount()
    let s = /storage/flowTokenVault
    let t = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()
    addTypeToCache(acct, namespace: DefaultNamespace, resourceType: Type<@FlowToken.Vault>(), capIssueType: t, path: s)

    let capType = CapabilityType(t)!
    txExecutor("get_ft_provider_capability_from_cache.cdc", [acct], [DefaultNamespace, Type<@FlowToken.Vault>(), capType])
}

access(all) fun testRemoveCachedCapability() {
    let acct = getNewAccount()
    let s = /storage/flowTokenVault
    let t = Type<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>()
    
    addTypeToCache(acct, namespace: DefaultNamespace, resourceType: Type<@FlowToken.Vault>(), capIssueType: t, path: s)
    let addEvent = Test.eventsOfType(Type<CapabilityCache.CapabilityAdded>()).removeLast() as! CapabilityCache.CapabilityAdded

    let capType = CapabilityType(t)!
    removeTypeFromCache(acct, namespace: DefaultNamespace, resourceType: Type<@FlowToken.Vault>(), capabilityType: capType, path: s)
    let removeEvent = Test.eventsOfType(Type<CapabilityCache.CapabilityRemoved>()).removeLast() as! CapabilityCache.CapabilityRemoved

    Test.assertEqual(addEvent.capabilityID, removeEvent.capabilityID)
}

// Helper Methods For tests
// ------------------------------------------------------

access(all) fun setupCache(_ acct: Test.TestAccount, namespace: String) {
    txExecutor("setup.cdc", [acct], [namespace])
}

access(all) fun addTypeToCache(_ acct: Test.TestAccount, namespace: String, resourceType: Type, capIssueType: Type, path: StoragePath) {
    txExecutor("add_type_to_cache.cdc", [acct], [namespace, resourceType, capIssueType, path])
}

access(all) fun removeTypeFromCache(_ acct: Test.TestAccount, namespace: String, resourceType: Type, capabilityType: Type, path: StoragePath) {
    txExecutor("remove_cached_capability.cdc", [acct], [namespace, resourceType, capabilityType])
}

// Test framework hooks
// ------------------------------------------------------

access(all) fun setup() {
    deployAll()
}