access(all) contract CapabilityCache {

    access(all) let basePathIdentifier: String

    access(all) event CapabilityAdded(owner: Address?, cacheUuid: UInt64, namespace: String, capabilityType: Type, capabilityID: UInt64)
    access(all) event CapabilityRemoved(owner: Address?, cacheUuid: UInt64, namespace: String, capabilityType: Type, capabilityID: UInt64)

    // Add to a namespace
    access(all) entitlement Add

    // Remove from a namespace
    access(all) entitlement Delete

    // Retrieve a cap from the namespace
    access(all) entitlement Get

    access(all) resource Cache {
        access(self) let caps: {Type: Capability}
        access(all) let namespace: String

        access(Delete) fun removeCapabilityByType(_ type: Type): Capability? {
            let cap = self.caps.remove(key: type)
            if cap != nil {
                emit CapabilityRemoved(owner: self.owner?.address, cacheUuid: self.uuid, namespace: self.namespace, capabilityType: type, capabilityID: cap!.id)
            }
            return cap
        }

        access(Add) fun addCapability(cap: Capability, type: Type) {
            pre {
                self.caps[type] == nil: "capability with given type is already registered"
            }

            self.caps[type] = cap
            emit CapabilityAdded(owner: self.owner?.address, cacheUuid: self.uuid, namespace: self.namespace, capabilityType: type, capabilityID: cap.id)
        }

        access(Get) fun getCapabilityByType(_ type: Type): Capability? {
            return self.caps[type]
        }

        init(namespace: String) {
            self.caps = {}
            self.namespace = namespace
        }
    }

    access(all) fun getPathForCache(_ namespace: String): StoragePath {
        return StoragePath(identifier: self.basePathIdentifier.concat(namespace))
            ?? panic("invalid namespace value")
    }

    access(all) fun createCache(namespace: String): @Cache {
        return <- create Cache(namespace: namespace)
    }

    init() {
        self.basePathIdentifier = "CapabilityCache_".concat(self.account.address.toString()).concat("_")
    }
}