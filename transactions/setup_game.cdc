import NonFungibleToken from 0xNFTADDRESS
import Jackpot from 0xJACKPOT


transaction {
    prepare(acct: AuthAccount) {
        // Create a new empty Jackpot collection
        if acct.borrow<&Jackpot.Collection>(from: Jackpot.CollectionStoragePath) == nil {
            let collection <- Jackpot.createEmptyCollection() as! @Jackpot.Collection
            acct.save<@Jackpot.Collection>(<-collection, to: Jackpot.CollectionStoragePath)
            acct.link<&{NonFungibleToken.CollectionPublic, Jackpot.JackpotCollectionPublic}>(Jackpot.CollectionPublicPath, target: Jackpot.CollectionStoragePath)
        }
    }
}