// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract MutlisigWallet {

error MutlisigWallet__NotEnoughOwners();
error MutlisigWallet__InvalidRequiredNumberOfOwners();
error MutlisigWallet__InvalidOwnerAddress();
error MutlisigWallet__NotUniqueOwner();
error MutlisigWallet__TransactionDoesNotExists();
error MutlisigWallet__TransactionAlreadyApproved();
error MutlisigWallet__TransactionAlreadyExecuted();
error MutlisigWallet__ApprovalsIsLessThanRequired();
error MutlisigWallet__TransactionFailed();
error MutlisigWallet__TransactionNotApproved();

    struct Transaction{
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approve;

    event Deposit(address indexed sender, uint indexed value);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);

    modifier onlyOwner(){
        if(!isOwner[msg.sender])
        {
            revert MutlisigWallet__InvalidOwnerAddress();
        }
        _;
    }

    modifier txExists(uint _txId) {
        if(_txId > transactions.length)
        {
            revert MutlisigWallet__TransactionDoesNotExists();
        }
        _;
    }

    modifier NotApproved(uint _txId) {
        if(approve[_txId][msg.sender]){
            revert MutlisigWallet__TransactionAlreadyApproved();
        }
        _;
    }

    modifier notExecuted(uint _txId){
        if(transactions[_txId].executed){
            revert MutlisigWallet__TransactionAlreadyExecuted();
        }
        _;
    }

   
    constructor(address[] memory _owners, uint256 _required){
        if(_owners.length < 0)
        {
            revert MutlisigWallet__NotEnoughOwners();
        }
        if(_required < 0 && _required <= owners.length)
        {
            revert MutlisigWallet__InvalidRequiredNumberOfOwners();
        } 
        for(uint256 i=0;i<_owners.length;i++)
        {
            address owner = _owners[i];
            if(owner == address(0))
            {
                revert MutlisigWallet__InvalidOwnerAddress();
            }
            if(!isOwner[owner]){
                revert MutlisigWallet__NotUniqueOwner();
            }
            owners.push(owner);
        }
        required = _required;
    }

    receive() external payable{
        emit Deposit(msg.sender,msg.value);
    }

    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner{
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data: _data,
            executed:false
        }));
    emit Submit(transactions.length -1);
    }

    function approved(uint _txId) external onlyOwner txExists(_txId) NotApproved(_txId) notExecuted(_txId){
        approve[_txId][msg.sender] = true;
        emit Approve(msg.sender,_txId);
    }

    function  _getApprovalCount(uint256 _txId) private view returns(uint256 count){
        for(uint256 i; i<owners.length;i++){
            if(approve[_txId][msg.sender])
            {
                count += 1;
            }
        }
        return count;
    }

    function execute(uint256 _txId) external txExists(_txId) notExecuted(_txId){
        if(_getApprovalCount(_txId) <= required)
        {
            revert MutlisigWallet__ApprovalsIsLessThanRequired();
        }
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value:transaction.value}(transaction.data);
 
        if(!success)
        {
            revert MutlisigWallet__TransactionFailed();
        }
        emit Execute(_txId);
    }

    function revoke(uint256 _txId) external onlyOwner txExists(_txId) NotApproved(_txId){
        if(!approve[_txId][msg.sender])
        {
            revert MutlisigWallet__TransactionNotApproved();
        }
        approve[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
    

}

