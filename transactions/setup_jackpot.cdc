import NonFungibleToken from 0xNFTADDRESS
import TopShot from 0xTOPSHOTADDRESS
import MetadataViews from 0xMETADATAVIEWSADDRESS
import Jackpot from 0xJACKPOT

// This transaction configures a user's account
// to use the NFT contract by creating a new empty collection,
// storing it in their account storage, and publishing a capability
transaction {
    prepare(acct: AuthAccount) {

        // taken from: https://github.com/dapperlabs/nba-smart-contracts/blob/master/transactions/user/setup_account.cdc
        if acct.borrow<&TopShot.Collection>(from: /storage/MomentCollection) == nil {
            let collection <- TopShot.createEmptyCollection() as! @TopShot.Collection
            acct.save(<-collection, to: /storage/MomentCollection)
            acct.link<&{NonFungibleToken.CollectionPublic, TopShot.MomentCollectionPublic, MetadataViews.ResolverCollection}>(/public/MomentCollection, target: /storage/MomentCollection)
        }

        // Create a new empty collection
        if acct.borrow<&Jackpot.Collection>(from: Jackpot.CollectionStoragePath) == nil {
            let collection <- Jackpot.createEmptyCollection() as! @Jackpot.Collection
            acct.save<@Jackpot.Collection>(<-collection, to: Jackpot.CollectionStoragePath)
            acct.link<&{NonFungibleToken.CollectionPublic, Jackpot.JackpotCollectionPublic}>(Jackpot.CollectionPublicPath, target: Jackpot.CollectionStoragePath)
        }
    }
}