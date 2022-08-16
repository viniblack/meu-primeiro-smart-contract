// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./03-token.sol";


contract Airdrop  {
  // Enum
  enum Status { PAUSED, ACTIVE, CANCELLED } // mesmo que uint8

  // Properties
  address private owner;
  address public tokenAddress;
  address[] private subscribers;
  mapping(address => bool) subscribersMapping;
  Status contractState; 

  // Modifiers
  modifier isOwner() {
    require(msg.sender == owner , "Sender is not owner!");
    _;
  }

  modifier isActived() {
    require(contractState == Status.ACTIVE, "The contract is not acvite!");
    _;
  }

  // Events
  event Killed(address killedBy);

  // Constructor
  constructor(address token) {
    owner = msg.sender;
    tokenAddress = token;
    contractState = Status.PAUSED;
  }

  // Public Functions
  function subscribe() public isActived returns(bool) {
    hasSubscribed(msg.sender);
    subscribersMapping[msg.sender] = true;
    subscribers.push(msg.sender);
    return true;
  }

  function execute() public isOwner isActived returns(bool) {
    uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
    uint256 amountToTransfer = balance / subscribers.length;
    for (uint i = 0; i < subscribers.length; i++) {
        require(subscribers[i] != address(0));
        require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
    }

    return true;
  }

  function state() public view returns(Status) {
    return contractState;
  }

  function setState(uint8 status) public isOwner {
    require(status <= 1, "Invalid status");

    if(status == 0) {
        require(contractState != Status.PAUSED, "The status is already PAUSED");
        contractState = Status.PAUSED;
    }else if(status == 1){
        require(contractState != Status.ACTIVE, "The status is already ACTIVE");
        contractState = Status.ACTIVE;
    }
  }

  // Private Functions
  function hasSubscribed(address subscriber) private view returns(bool) {
    require(subscribersMapping[subscriber] != true, "You already registered");
    
    return true;
  }

  function kill() public isOwner {
    contractState = Status.CANCELLED;
    emit Killed(msg.sender);
    selfdestruct(payable(owner));
  } 
}