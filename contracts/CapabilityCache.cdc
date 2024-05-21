access(all) contract CapabilityCache {

    access(all) let basePathIdentifier: String

    // Add to a namespace
    access(all) entitlement Add

    // Remove from a namespace
    access(all) entitlement Delete

    // Retrieve a cap from the namespace
    access(all) entitlement Get

    access(all) resource Cache {
        access(self) let caps: {Type: Capability}

        access(Delete) fun removeCapabilityByType(_ type: Type): Capability? {
            return self.caps.remove(key: type)
        }

        access(Add) fun addCapability(cap: Capability, type: Type) {
            pre {
                self.caps[type] == nil: "capability with given type is already registered"
            }

            self.caps[type] = cap
        }

        access(Get) fun getCapabilityByType(_ type: Type): Capability? {
            return self.caps[type]
        }

        init() {
            self.caps = {}
        }
    }

    access(all) fun getPathForCache(_ namespace: String): StoragePath {
        return StoragePath(identifier: self.basePathIdentifier.concat(namespace))
            ?? panic("invalid namespace value")
    }

    access(all) fun createCache(): @Cache {
        return <- create Cache()
    }

    init() {
        self.basePathIdentifier = "CapabilityCache_".concat(self.account.address.toString()).concat("_")
    }
}