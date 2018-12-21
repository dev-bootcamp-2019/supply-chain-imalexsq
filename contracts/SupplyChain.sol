/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here:
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SupplyChain {

    address public owner;
    uint public skuCount;

 
    mapping (uint => Item) public items;

    enum State { ForSale, Sold, Shipped, Received }
 
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);

    modifier isOwner() {require(msg.sender == owner,"Error in isOwner"); _;}
    modifier verifyCaller(address _address) {require(msg.sender == _address, "Error verifyCaller"); _;}
    modifier paidEnough(uint _price) {require(msg.value >= _price, "Error in paidEnough"); _;}
    modifier checkValue(uint _sku) {
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        address(items[_sku].buyer).transfer(amountToRefund);
    }

    modifier forSale(uint _sku) {require(items[_sku].state == State.ForSale, "Error in forSale"); _;}
    modifier sold(uint _sku) {require(items[_sku].state == State.Sold, "Error in sold");_;}
    modifier shipped(uint _sku) { require(items[_sku].state == State.Shipped); _;}
    modifier received(uint _sku) {require(items[_sku].state == State.Received, "Error in received"); _;}


    constructor() payable public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint _price) public returns(bool){
        emit ForSale(skuCount);
        items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
        skuCount = skuCount + 1;
        return true;
    }

    /* Add a keyword so the function can be paid. This function should transfer money
        to the seller, set the buyer as the person who called this transaction, and set the state
        to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
        if the buyer paid enough, and check the value after the function is called to make sure the buyer is
        refunded any excess ether sent. Remember to call the event associated with this function!*/

    function buyItem(uint sku)
        public
        payable
        
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {

        items[sku].buyer = msg.sender;
        items[sku].seller.transfer(items[sku].price);
        items[sku].state = State.Sold;
        
        emit Sold(sku);

    }

    /* Add 2 modifier to check if the item is sold already, and that the person calling this function
    is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
    function shipItem(uint sku) sold(sku)  verifyCaller(items[sku].seller)  
        public
    {
        items[sku].state = State.Shipped;
        emit Shipped(sku);
    }

    /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
    is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint sku) shipped(sku) verifyCaller(items[sku].buyer)
        public
    {
        items[sku].state = State.Received;
        emit Received(sku);
    }

    /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }

}
