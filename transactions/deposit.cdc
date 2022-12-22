import Jackpot from 0xJACKPOT
import NonFungibleToken from 0xNFTADDRESS
import TopShot from 0xTOPSHOTADDRESS

transaction(recipient: Address, tokenID: UInt64) {

    let transferToken: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&TopShot.Collection>(from: /storage/MomentCollection)
            ?? panic("Could not borrow a reference to the stored Moment collection")
        
        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: tokenID)
    }

    execute {
        let recipient = getAccount(recipient)
        let receiverRef = recipient.getCapability(Jackpot.CollectionPublic).borrow<&{Jackpot.JackpotCollectionPublic}>()!
        receiverRef.deposit(token: <-self.transferToken)
    }
}
