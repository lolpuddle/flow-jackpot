import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NonFungibleToken from 0xNFTADDRESS
import MetadataViews from 0xMETADATAVIEWSADDRESS

pub contract Jackpot {

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    access(self) var pot: [UInt64]
    access(self) var potThreshold: UInt32
    access(self) var vault: {UInt64: Address}

    pub resource interface JackpotCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
    }

    pub resource Collection: JackpotCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        pub var ownershipDict: {Uint64: Address}

        init {
            ownedNFTs = {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            if ownershipDict[withdrawID] == nil {
                panic("Cannot withdraw: Token not owned by withdrawer")
            }
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Cannot withdraw: Cannot find token")
            return <- token
        }

        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            var batchCollection <- create Collection()
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            return <-batchCollection
        }

        // The contract acts as an escrow account in which you will be able to deposit NFTs to, and also withdraw NFTs from
        pub fun deposit(token: @NFT) {
            ownershipDict[token.id] = self.owner?.address
            let oldToken <- self.ownedNFTs[id] <- token
            destroy oldToken
        }

        pub fun getIDs(): [Uint64] {
            return self.ownedNFTs.keys
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create Jackpot.Collection()
    }

    // Returns the IDs of the NFTs currently submitted for the jackpot
    pub fun getCurrentPot(): [Uint64] {
        return Jackpot.pot.keys
    }

    pub fun getPotThreshold(): Uint32 {
        return Jackpot.potThreshold
    }

    pub fun submitToJackpot(token: UInt64) {
        if !self.pot.contains(token) && vault[token] == self.owner?.address {
            self.pot.append(token)

            if self.pot.length == self.potThreshold {
                // select a winner
                rand = unsafeRandom() % self.potThreshold
                winner = self.vault[self.pot[rand]]

                // assign ownership of NFT to winner
                for submission in pot {
                    vault[submission] = winner
                }

                // reset pot
                self.pot = []
            }
        }
    }

    // Allows users to submit multiple NFTs at once. If the bulk submit exceeds the threshold, the transaction is rejected.
    // This is to prevent unfair manipulation in the odds of winning. Eg, if the threshold to trigger the jackpot game is 10
    // Then a malicious actor could bulk submit 10000 NFTs to the pot after the pot has reached 99 entries.
    pub fun bulkSubmit(tokens: [UInt64]) {
        if self.potThreshold >= (tokens.length + self.pot.length) {
            for token in tokens {
                Jackpot.submitToJackpot(token)
            }
        }
    }

    init {
        self.CollectionPublicPath = /public/jackpotStorageCollection
        self.CollectionStoragePath = /storage/jackpotStorageCollection
        self.potThreshold = 10
        self.pot = []
        self.vault = {}
    }
}