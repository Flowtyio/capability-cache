/*
https://github.com/Flowtyio/capability-cache

CapabilityCache helps manage capabilities which are issued but are not in public paths.
Rather than looping through all capabilities under a storage path and finding one that 
matches the Capability type you want, the cache can be used to retrieve them
*/
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

    // Resource that manages capabilities for a provided namespace. Only one capability is permitted per type.
    access(all) resource Cache {
        access(self) let caps: {Type: Capability}
        access(self) let ids: {UInt64: Type}

        access(all) let namespace: String

        // Remove a capability, if it exists, 
        access(Delete) fun removeCapabilityByType(_ type: Type): Capability? {
            let cap = self.caps.remove(key: type)
            if cap != nil {
                emit CapabilityRemoved(owner: self.owner?.address, cacheUuid: self.uuid, namespace: self.namespace, capabilityType: type, capabilityID: cap!.id)
            }

            return cap
        }

        // Adds a capability to the cache. If there is already an entry for the given type,
        // it will be returned
        access(Add) fun addCapability(cap: Capability, type: Type): Capability? {
            pre {
                cap.id != 0: "cannot add a capability with id 0"
            }

            emit CapabilityAdded(owner: self.owner?.address, cacheUuid: self.uuid, namespace: self.namespace, capabilityType: type, capabilityID: cap.id)
            self.ids[cap.id] = type
            return self.caps.insert(key: type, cap)
        }

        // Retrieve a capability key'd by a given type.
        access(Get) fun getCapabilityByType(_ type: Type): Capability? {
            return self.caps[type]
        }

        access(all) fun getTypes(): [Type] {
            return self.caps.keys
        }
        
        access(all) fun getIDs(): [UInt64] {
            return self.ids.keys
        }

        access(all) fun getIdByType(_ id: UInt64): Type? {
            return self.ids[id]
        }

        init(namespace: String) {
            self.caps = {}
            self.ids = {}

            self.namespace = namespace
        }
    }

    // There is no uniform storage path for the Capability Cache. Instead, each platform which issues capabilities
    // should manage their own cache, and can generate the storage path to store it in with this helper method
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