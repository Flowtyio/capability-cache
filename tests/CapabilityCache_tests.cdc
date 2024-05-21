import Test
import "test_helpers.cdc"

// Tests
// ------------------------------------------------------
access(all) fun testImport() {
    Test.assert(scriptExecutor("import.cdc", [])! as! Bool, message: "import script failed")
}

// Helper Methods For tests
// ------------------------------------------------------

// Test framework hooks
// ------------------------------------------------------

access(all) fun setup() {
    deployAll()
}