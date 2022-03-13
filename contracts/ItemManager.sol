pragma solidity ^0.6.0;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {

    enum SupplyChainState{ Created, Paid, Delivered }
    
    struct S_item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
    }

    mapping(uint => S_item) public items;
    uint itemIndex;

    

    event SupplyChainStep(uint _itemIndex, uint _step);

    function createItem (string memory _identifier, uint _itemPrice) public onlyOwner { 
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier;
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
        itemIndex++;
    }

    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._itemPrice == msg.value,"Only full payments accepted, item price is invalid.");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Might be elsewhere in the supply chain, item was not created.");
        items[_itemIndex]._state = SupplyChainState.Paid;

        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
    }

    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Might be elsewhere in the supply chain, item was not created.");
        items[_itemIndex]._state = SupplyChainState.Delivered;
        
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state));
    }
}