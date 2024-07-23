# pragma version ^0.4.0
"""
@title Birthday Wonder Trade
@license GNU Affero General Public License v3.0 only
@author Alice Rozengarden
"""

# This contract is implementing the erc1155 receivers functionality
from snekmate.tokens.interfaces import IERC1155Receiver
implement: IERC1155Receiver

# we will need to interact with all those kind of token/nft
from snekmate.tokens.interfaces import IERC1155
from ethereum.ercs import IERC721 
from ethereum.ercs import IERC20 

# erc165 stuff
_SUPPORTED_INTERFACES: constant(bytes4[1]) = [0x01FFC9A7]
# storing the collection address
COLLECTION: immutable(IERC1155)
# the address to receive the rescued funds
RESCUE: immutable(address)
# the address alllowed to save the funds
ADMIN: immutable(address)
# boolean to see if the contract been seeded or not
isSeeded: public(bool)
# Address of the contract seeder
seeder: public(address)
# id of th currently stored NFT
storedId: public(uint256)

@deploy
def __init__(_birthday_card_address: address, _rescue_address: address):
    COLLECTION = IERC1155(_birthday_card_address)
    RESCUE = _rescue_address
    ADMIN = msg.sender
    self.isSeeded = False

@external
@view
def supportsInterface(interfaceId: bytes4) -> bool:
    """
    @dev Returns `True` if this contract implements the
         interface defined by `interfaceId`.
    @notice For more details on how these identifiers are
            created, please refer to:
            https://eips.ethereum.org/EIPS/eip-165.
    @param interfaceId The 4-byte interface identifier.
    @return bool The verification whether the contract
            implements the interface or not.
    """
    return interfaceId in _SUPPORTED_INTERFACES

@external
def onERC1155Received(_operator: address, _from: address, _id: uint256, _value: uint256, _data: Bytes[1_024]) -> bytes4:
    """
    @dev Handles the receipt of a single ERC-1155 token type.
         This function is called at the end of a `safeTransferFrom`
         after the balance has been updated.
    @notice It must return its function selector to
            confirm the token transfer. If any other value
            is returned or the interface is not implemented
            by the recipient, the transfer will be reverted.
    @param _operator The 20-byte address which called
           the `safeTransferFrom` function.
    @param _from The 20-byte address which previously
           owned the token.
    @param _id The 32-byte identifier of the token.
    @param _value The 32-byte token amount that is
           being transferred.
    @param _data The maximum 1,024-byte additional data
           with no specified format.
    @return bytes4 The 4-byte function selector of `onERC1155Received`.
    """
    assert _value == 1, "Only support one token at a time"
    if self.isSeeded:
        extcall COLLECTION.safeTransferFrom(self, _from, self.storedId, 1, empty(Bytes[1_024]))
    else:
        self.isSeeded = True
        self.seeder = _from
    self.storedId = _id
    return method_id("onERC1155Received(address,address,uint256,uint256,bytes)", output_type=bytes4)


@external
def onERC1155BatchReceived(_operator: address, _from: address, _ids: DynArray[uint256, 65_535], _values: DynArray[uint256, 65_535],
                           _data: Bytes[1_024]) -> bytes4:
    """
    @dev Handles the receipt of multiple ERC-1155 token types.
         This function is called at the end of a `safeBatchTransferFrom`
         after the balances have been updated.
    @notice It must return its function selector to
            confirm the token transfers. If any other value
            is returned or the interface is not implemented
            by the recipient, the transfers will be reverted.
    @param _operator The 20-byte address which called
           the `safeBatchTransferFrom` function.
    @param _from The 20-byte address which previously
           owned the tokens.
    @param _ids The 32-byte array of token identifiers. Note
           that the order and length must match the 32-byte
           `_values` array.
    @param _values The 32-byte array of token amounts that are
           being transferred. Note that the order and length must
           match the 32-byte `_ids` array.
    @param _data The maximum 1,024-byte additional data
           with no specified format.
    @return bytes4 The 4-byte function selector of `onERC1155BatchReceived`.
    """
    raise "Only support one token at a time"

def withdraw() -> bool:
    """
    @dev Allow the one hat seeded the contract to get the stored NFT
    @return bool True on sucess
    """
    assert msg.sender == self.seeder, "Only for the seeder"
    extcall COLLECTION.safeTransferFrom(self, self.seeder, self.storedId, 1, empty(Bytes[1_024]))
    self.isSeeded = False
    return True

def save20(_address: address, _amount: uint256) -> bool:
    """
    @dev allow the admin to rescue stuck fund to rescue address
    @param _address the address of the rescued erc20 token
    @param _amount the amount of rescued erc20 token
    @return bool wether transfer been successful
    """
    assert msg.sender == ADMIN, "only the admin can rescue funds"
    return extcall IERC20(_address).transfer(RESCUE, _amount)
