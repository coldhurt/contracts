// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MutliSigWallet {
  address[] public owners;
  mapping(address => bool) public isOwner;
  mapping(uint256 => mapping(address => bool)) public approved;

  struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bool executed;
  }

  Transaction[] public transactions;
  uint256 numConfirmationsRequired;

  event Submit(uint256 indexed txId, address indexed owner);
  event Approve(uint256 indexed txId, address indexed owner);
  event Deposit(address indexed sender, uint amount, uint balance);
  event Execute(uint indexed txIndex, address indexed owner);

  constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
    require(_owners.length > 0, "owners required");
    require(
      _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
      "invalid number of required confirmations"
    );

    for (uint256 i = 0; i < _owners.length; i++) {
      address owner = _owners[i];

      require(owner != address(0), "invalid owner");
      require(!isOwner[owner], "owner not unique");

      isOwner[owner] = true;
      owners.push(owner);
    }

    numConfirmationsRequired = _numConfirmationsRequired;
  }

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier notApproved(uint256 txId, address addr) {
    require(!approved[txId][addr], "tx already approved");
    _;
  }

  modifier isExist(uint256 txId) {
    require(txId < transactions.length, "tx not exist");
    _;
  }

  modifier notExecuted(uint256 txId) {
    require(!transactions[txId].executed, "has executed");
    _;
  }

  function getApproveCount(uint256 txId) private view returns (uint256 count) {
    for (uint256 i = 0; i < owners.length; i++) {
      if (approved[txId][owners[i]]) {
        count++;
      }
    }
  }

  function submit(address to, uint256 value, bytes memory data) external onlyOwner {
    transactions.push(Transaction(to, value, data, false));
    emit Submit(transactions.length - 1, msg.sender);
  }

  function approve(
    uint256 txId
  ) external onlyOwner isExist(txId) notApproved(txId, msg.sender) notExecuted(txId) {
    approved[txId][msg.sender] = true;
    emit Approve(txId, msg.sender);
  }

  function execute(uint256 txId) external onlyOwner isExist(txId) {
    require(getApproveCount(txId) >= numConfirmationsRequired, "not approved");
    Transaction storage _tx = transactions[txId];
    (bool success, ) = _tx.to.call{value: _tx.value}(_tx.data);
    _tx.executed = true;
    require(success, "failed");
    emit Execute(txId, msg.sender);
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }
}

contract TestContract {
  uint public i;

  function callMe(uint j) public payable {
    i += j;
  }

  function getData() public pure returns (bytes memory) {
    return abi.encodeWithSignature("callMe(uint256)", 123);
  }
}
