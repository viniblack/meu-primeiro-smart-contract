// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {

  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address recipient, uint256 amount) external returns(bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function increaseAllowance(address spender, uint256 addedValue) external  returns (bool) ;
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) ;

  event Transfer(address from, address to, uint256 value);
  event Approval(address owner, address spender, uint256 value);

}

contract CryptoCoin is IERC20 {
  // Enum
  enum Status { PAUSED, ACTIVE, CANCELLED }

  //Properties
  address private owner;
  string public constant name = "CryptoCoin";
  string public constant symbol = "CRC";
  uint8 public constant decimals = 18;
  uint256 private totalsupply;
  Status contractState;
  uint256 valorToken;
  mapping(address => mapping (address => uint256)) allowed;
  mapping(address => uint256) private addressToBalance;

  // Modifiers
  modifier isOwner() {
    require(msg.sender == owner , "Sender is not owner!");
    _;
  }

  modifier isActive() {
    require(contractState == Status.ACTIVE, "Contract is not Active!");
    _;
  }

  // Events
  event Mint(address owner, uint256 BalanceOwner, uint256 amount, uint256 supply);
  event Burn(address owner, uint256 value, uint256 supply);


  //Constructor
  constructor(uint256 total) {
    owner = msg.sender;
    totalsupply = total;
    addressToBalance[msg.sender] = totalsupply;
    contractState = Status.ACTIVE;
  }

  //Public Functions
  function totalSupply() public override view returns(uint256) {
    return totalsupply;
  }

  function balanceOf(address tokenOwner) public override view returns(uint256) {
    return addressToBalance[tokenOwner];
  }

  function transfer(address recipient, uint256 amount) public isActive override returns(bool) {
    require(amount <= addressToBalance[msg.sender], "Insufficient Balance to Transfer");

    addressToBalance[msg.sender] -= amount;
    addressToBalance[recipient] += amount;

    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address from, address spender) public override view returns (uint) {
    return allowed[from][spender];
  }
  
  function approve(address spender, uint256 amount) public override returns (bool) {
    allowed[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)public isActive override returns(bool) {
    require(amount > 0, "Tranfer value invalid is not zero.");
    require(amount <= balanceOf(sender), "Insufficient Balance to Transfer");
    require(amount <= allowed[sender][msg.sender], "No allowed");

    addressToBalance[sender] -= amount;
    allowed[sender][msg.sender] -= amount;
    addressToBalance[recipient] += amount;

    emit Transfer(sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public override returns (bool){
    require(spender != address(0), "Invalid address!");

    allowed[msg.sender][spender] += addedValue;

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
    require(spender != address(0), "Invalid address!");

    allowed[msg.sender][spender] -= subtractedValue;

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
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

  function mint(uint256 amount) public isActive isOwner {
    require(amount > 0, "Invalid mint value.");

    totalsupply += amount;
    addressToBalance[owner] += amount;

    emit Mint(owner, addressToBalance[owner], amount, totalSupply());       
  }

  function burn(uint256 amount) public isActive isOwner {
    require(amount > 0, "Invalid burn value.");
    require(totalSupply() >= amount, "The amount exceeds your balance.");
    require(balanceOf(owner) >= amount, "The value exceeds the owner's available amount");

    totalsupply -= amount;
    addressToBalance[owner] -= amount;

    emit Burn(owner, amount, totalSupply());
  }

  // Kill
  function kill() public isOwner {
    contractState = Status.CANCELLED;
    selfdestruct(payable(owner));
  } 
}
